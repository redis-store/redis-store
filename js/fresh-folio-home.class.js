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
		running		: false
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

    slideObserver: function(){
        var self = this;
		
        // prev button
        $(".scroll_prev").click(function(){
			
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
        $(".scroll_next").click(function(){
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
			self.options.slider_panel.find('li').click(function(){
				
				var feature_step = $(this).index() + 1;    
				
				if(!self.options.running){
					self.projectSlide(feature_step);
				}
				
				if(!$(this).hasClass('on') && !$(this).hasClass('active')){
					return false;
				}
			});
		}
    },
	
    projectSlide: function(step, direction){
        var self = this;
		var direction = 'prev';
		
		
        // adjust step
        step = step - 1;
	
		if(self.options.curr_step < step){
			direction = 'next';
		}
		
        if(self.options.curr_step != step){
            
			self.options.running = true;
			
            // set current step
            self.options.curr_step = step;

            // calculated marginLeft value
            var marginLeft =  self.options.size.step * step;
    
			
			
			// remove class from last active element
			self.options.slider_panel.find('li.on')
				.find('.slide_content')
					.animate({opacity: 0}, 450, function(){
						
					})
					
			// fade out image tp 0.45
			self.options.slider_panel.find('li.on').find(".border_image img").animate({opacity: 0.45}, 650);
			
			self.options.slider_panel.find('li.on').removeClass('on');

			 // fade back view port element
			self.options.slider_panel.find('li').eq(step)
				.find('.border_image img')
					.animate({opacity: 1}, 650, function(){
						self.options.slider_panel.find('li').eq(step).addClass('on');
					});		
					
					
			if(direction == 'prev'){		
				// fade in text
				self.options.slider_panel.find('li').eq(step).find(".slide_content").animate({opacity: 1}, 350);	
			}
			
			if(direction == 'next'){
				// fade in text
				self.options.slider_panel.find('li').eq(step).find(".slide_content").delay(250).animate({opacity: 1}, 450);	
			}
				
			self.options.slider_panel.animate({
				left : "-" + marginLeft + "px"
			},  650, 'easeInOutExpo', function(){

				self.options.running = false;
			});		
        }
    }
}