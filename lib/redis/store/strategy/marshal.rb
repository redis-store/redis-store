class Redis
  class Store < self
    module Strategy
      module Marshal
        private
          def _dump(object)
            ::Marshal.dump(object)
          end

          def _load(string)
            ::Marshal.load(string)
          end
      end
    end
  end
end
