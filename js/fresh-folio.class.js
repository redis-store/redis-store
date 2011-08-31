/**
 * freshFolioEvents - class for freshfolio website
 * Andrei Dinca
 */
var freshFolioEvents = {
    options: {
        size : {
            mainslider : 0,
            step       : 0
        },
        scroll_pane : '',
        slide_panel : '',
		click_slide : false,
        curr_step   : 0,
		header_slide: true,
		running		: false,
		home_controller: false,
		use_fade: false
    },

    init: function(setoption){
        var self = this;
        $.extend(self.options, setoption);

        // set default count of pages
        $("#filter_pages").text(self.options.size.mainslider < 10 ? "0" + self.options.size.mainslider : self.options.size.mainslider);

        // start click observer for project slider
        self.slideObserver();
		
		if(self.options.header_slide){
			// init drag slider
			self.initSlide(setoption);
		}
		
		self.options.slider_panel.width( (self.options.size.mainslider + 1) * self.options.size.step);
    },

    initSlide: function(setoption, start_from, reset){
		$("#slider").slider({
			min: 1,
			animate: true,
			max: setoption.size.mainslider,
			stop: function( event, ui ) {
				freshFolioEvents.projectSlide(ui.value);
			}
		});
		
		// inactive slider if mainslider size <= 1
		if(setoption.size.mainslider <= 1){
			$(".filter_scroll").css('opacity', 0.5).find('.ui-slider-handle').css('cursor', 'default').css('background-image', 'url(images/scroll_pane_inactiv.png)');
		}
    },

    slideObserver: function(){
        var self = this;
		
        // prev button
        $("#filter_prev, .scroll_prev").click(function(){
			
            var feature_step = self.options.curr_step;
            // no more minus than 0
            if(feature_step < 1){
                feature_step = self.options.size.mainslider;
            }
            if(!self.options.running){
				self.projectSlide(feature_step);
			}
        });

        // next button
        $("#filter_next, .scroll_next").click(function(){
            var feature_step = self.options.curr_step + 2;
            
            // no more plus than 0
            if(feature_step > self.options.size.mainslider){
                feature_step = 1;
            }
			
			if(!self.options.running){
				self.projectSlide(feature_step);
			}
        });
		
		if(self.options.click_slide){
			// slide on click
			self.options.slider_panel.find('li').not('active').click(function(){
				var feature_step = $(this).index() + 1;    
				
				if(!self.options.running){
					self.projectSlide(feature_step);
				}
				
				return false;
			});
		}
		
		$('.about_slide_to li').click(function(){
			var feature_step = $(this).index() + 1;  
			
			$('.about_slide_to li.active').removeClass('active');
			
			$('.about_slide_to li').eq($(this).index()).addClass('active');
			if(!self.options.running){
				self.projectSlide(feature_step);
			}
			
			return false;
		});
		
		$('.add_comment, .join_link').click(function(){
			self.projectSlide(self.options.size.mainslider);
			return false;
		});
    },

    projectSlide: function(step){
        var self = this;
		
        // adjust step
        step = step - 1;

        if(self.options.curr_step != step){
            
			self.options.running = true;
			
            // set current step
            self.options.curr_step = step;

            // calculated marginLeft value
            var marginLeft =  self.options.size.step * step;
            // move projects to specific step (params)
 
			if(self.options.use_fade){
				self.options.slider_panel.find('li.active').find(".project_buttons, .button_link").animate({opacity: 0}, 650);
				
				// remove class from last active element
				self.options.slider_panel.find('li.active')
					.find('img, .slide_content, .slide_text')
						.animate({opacity: 0.45}, 650, function(){
							self.options.slider_panel.find('li.active').removeClass('active');

						});


				self.options.slider_panel.find('li').eq(step)
					.find('img, .slide_content, .slide_text')
						.animate({opacity: 1}, 650, function(){
							self.options.slider_panel.find('li').eq(step).addClass('active');
						});	
			}
			
			// set slider to step
			$( "#slider" ).slider( "value", step + 1 );
			
            self.options.slider_panel.animate({
                left : "-" + marginLeft + "px"
            },  650, 'easeInOutExpo', function(){
                
                // cache object
                var $this = $(this);

                // print position
                var print_position = self.options.curr_step + 1;
                // show current page
                $("#filter_current").text(print_position < 10 ? "0" + print_position : print_position);
				
				$('.about_slide_to li.active').removeClass('active');
				$('.about_slide_to li').eq(self.options.curr_step).addClass('active');
				
				if(self.options.use_fade){
					$(".active").find(".project_buttons, .button_link").css('opacity', 0).animate({opacity: 1}, 650);
					$(".active").find(".project_buttons").css('display', 'block')
				}
				
				self.options.running = false;
            });
        }
    }
}