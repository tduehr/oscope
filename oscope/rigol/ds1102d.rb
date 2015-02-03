require 'airby'

module Oscope
  module Rigol
    # @note The command +display+ has been replaced with +sdisplay+
    class Ds1102d
      def self.mode_hash modes, mode_comm, addl_comm = {}
        Hash.new{|h,k| h[k] = modes[k].merge(mode_comm) if modes.has_key? k}.merge(addl_comm)
      end

      ZERO = [0]
      ONE = [1]
      ONE_ZERO = [0,1]

      ALTERNATION = {
        'edge' => {'slope' => ZERO,'slope=' => ONE},
        'slope' => {
          'window' => ZERO,
          'level_a' => ZERO,
          'level_b' => ZERO,
          'window=' => ONE,
          'level_a=' => ONE,
          'level_b=' => ONE
        },
        'video' => {
          'polarity' => ZERO,
          'standard' => ZERO,
          'line' => ZERO,
          'polarity=' => ONE,
          'standard=' => ONE,
          'line=' => ONE
        }
      }

      MODE = {
        'edge' => {
          'slope' => ZERO,
          'sensitivity' => ZERO,
          'slope=' => ONE,
          'sensitivity=' => ONE
        },
        'pulse' => {
          'mode' => ZERO,
          'sensitivity' => ZERO,
          'width' => ZERO,
          'mode=' => ONE,
          'sensitivity=' => ONE,
          'width=' => ONE
        },
        'video' => {
          'line' => ZERO,
          'mode' => ZERO,
          'polarity' => ZERO,
          'sensitivity' => ZERO,
          'standard' => ZERO,
          'line=' => ONE,
          'mode=' => ONE,
          'polarity=' => ONE,
          'sensitivity=' => ONE,
          'standard=' => ONE
        },
        'slope' => {
          'level_a' => ZERO,
          'level_b' => ZERO,
          'mode' => ZERO,
          'sensitivity' => ZERO,
          'time' => ZERO,
          'window' => ZERO,
          'level_a=' => ONE,
          'level_b=' => ONE,
          'mode=' => ONE,
          'sensitivity=' => ONE,
          'time=' => ONE,
          'window=' => ONE
        },
        'pattern' => {
          'pattern' => ZERO,
          'pattern=' => [2,4]
        },
        'duration' => {
          'pattern' => ZERO,
          'time' => ZERO,
          'qualifier' => ZERO,
          'pattern=' => [2],
          'time=' => ONE,
          'qualifier=' => ONE
        },
        'alternation' => mode_hash( ALTERNATION, {
            'level' => ZERO,
            'time' => ZERO,
            'coupling' => ZERO,
            'sensitivity' => ZERO,
            'holdoff' => ZERO,
            'level=' => ONE,
            'time=' => ONE,
            'coupling=' => ONE,
            'sensitivity=' => ONE,
            'holdoff=' => ONE
          }, {
            'type' => ZERO,
            'source' => ZERO,
            'time_scale' => ZERO,
            'time_offset' => ZERO 
          }
        )
      }
      attr_accessor :session, :options

      def self.open resource, opts = {}
        ret = self.new resource, opts = {}
        if block_given?
          begin
            yield ret
          ensure
            ret.close
          end
        end
        ret
      end

      def open resource = nil
        @resource = resource if resource
        @session.open @resource
    
        self
      end

      def initialize resource = nil, opts = {}
        if opts[:session]
          @session = opts.delete(:session)
        elsif resource
          @session = Airby::Session.new(resource)
        else
          @session = Airby::Session.new
          @session.open @session.find_resources("?*").first unless opts[:no_auto]
        end
        @resource = @session.address

        @session.buffer_grow opts[:buffer_size] if opts[:buffer_size]
        @options = opts
      end

      def mode_hash modes, mode_comm, addl_comm = {}
        self.class.mode_hash modes, mode_comm, addl_comm
      end

      # @group General Commands

      # get device identification string
      # @return [String]
      def ident
        @session.ident
      end

      # Reset device parameters
      # @return [void]
      def reset
        @session.reset
      end

      # @endgroup

      # @group System Commands

      # initiates ongoing data collection within the device
      def run
        @session.write ':RUN'
      end

      # instructs oscilloscope to determine optimal display parameters for waveform
      def auto
        @session.write ':AUTO'
      end

      # writes a bmp to the USB disk of the current screen information
      def hardcopy
        @session.write ':HARDCOPY'
      end

      # @endgroup

      # @group Acquire Commands

      def acquire
        Relation::Base.new self, ":ACQUIRE", {
          'type' => ZERO,
          'type=' => ONE,
          'mode' => ZERO,
          'mode=' => ONE,
          'averages' => ZERO,
          'averages=' => ONE,
          'sampling_rate' => ONE,
          'memdepth' => ZERO,
          'memdepth=' => ONE
        }
      end

      # @endgroup

      # @group Display Commands

      def sdisplay
        Relation::Base.new self, ':DISPLAY', {
          'type' => ZERO,
          'type=' => ONE,
          'grid' => ZERO,
          'grid=' => ONE,
          'persist' => ZERO,
          'persist=' => ONE,
          'mnudisplay' => ZERO,
          'mnudisplay=' => ONE,
          'mnustatus' => ZERO,
          'mnustatus=' => ONE,
          'clear' => ZERO,
          'brightness' => ZERO,
          'brightness=' => ONE,
          'intensity' => ZERO,
          'intensity=' => ONE
        }
      end

      # @endgroup

      # @group Timebase Commands
      def timebase
        Relation::Base.new self, ':TIMEBASE', {
          'mode' => ZERO,
          'mode=' => ONE,
          'delayed' => {
            'offset' => ZERO,
            'offset=' => ONE,
            'scale' => ZERO,
            'scale=' => ONE
          },
          'offset' => ZERO,
          'offset=' => ONE,
          'scale' => ZERO,
          'scale=' => ONE,
          'format' => ZERO,
          'format=' => ONE
        }
      end
      # @endgroup

      # @group Trigger Commands
      def trigger
        hsh = mode_hash MODE, {
            'source' => ZERO,
            'level' => ZERO,
            'sweep' => ZERO,
            'coupling' => ZERO,
            'source=' => ONE,
            'level=' => ONE,
            'sweep=' => ONE,
            'coupling=' => ONE
        },
        {
          'mode' => ZERO,
          'holdoff' => ZERO,
          'status' => ZERO,
          'mode=' => ONE,
          'holdoff=' => ONE
        }

        Relation::Base.new self, ':TRIGGER', hsh
      end

      def trig_50
        @session.write(':TRIG%50')
      end

      def force_trig
        @session.write ':FORCETRIG'
      end

      # @endgroup

      # @group Storage Commands
      def storage
        Relation::Base.new self, ':STORAGE', {'factory' => {'load' => ZERO}}
      end
      # @endgroup

      # @group Math Commands
      def fft
        Relation::Base.new self, ':FFT', {'sdisplay' => ZERO, 'sdisplay=' => ONE}
      end

      def math
        Relation::Base.new self, ':MATH', {
          'sdisplay' => ZERO,
          'operate' => ZERO,
          'sdisplay=' => ONE,
          'operate=' => ONE
        }
      end
      # @endgroup

      # @group Channel Commands
      def channel chan
        raise ArgumentError 'channel must be 1 or 2' unless chan == 1 || chan == 2
        Relation::Base.new self, ":CHANNEL#{chan}", {
          'bw_limit' => ZERO,
          'coupling' => ZERO,
          'sdisplay' => ZERO,
          'invert' => ZERO,
          'offset' => ZERO,
          'probe' => ZERO,
          'scale' => ZERO,
          'filter' => ZERO,
          'memory_depth' => ZERO,
          'vernier' => ZERO,
          'bw_limit=' => ONE,
          'coupling=' => ONE,
          'sdisplay=' => ONE,
          'invert=' => ONE,
          'offset=' => ONE,
          'probe=' => ONE,
          'scale=' => ONE,
          'filter=' => ONE,
          'vernier=' => ONE
        }
      end
      # @endgroup

      # @group Measure Commands
      def measure
        ret = Relation::Base.new self, ':MEASURE', {
          'vpp' => ONE_ZERO,
          'vmax' => ONE_ZERO,
          'vmin' => ONE_ZERO,
          'vamplitude' => ONE_ZERO,
          'vtop' => ONE_ZERO,
          'vbase' => ONE_ZERO,
          'vaverage' => ONE_ZERO,
          'vrms' => ONE_ZERO,
          'overshoot' => ONE_ZERO,
          'preshoot' => ONE_ZERO,
          'frequency' => ONE_ZERO,
          'rise_time' => ONE_ZERO,
          'fall_time' => ONE_ZERO,
          'period' => ONE_ZERO,
          'pwidth' => ZERO,
          'nwidth' => ZERO,
          'pduty_cycle' => ZERO,
          'nduty_cycle' => ZERO,
          'pdelay' => ZERO,
          'ndelay' => ZERO,
          'total' => ZERO,
          'total=' => ONE,
          'source' => ZERO,
          'source=' => ONE
        }
        class << ret
          def clear
            @scope.write "#{@command}:CLEAR"
          end
        end
        ret
      end

      # @endgroup

      # @group Waveform Commands
      def waveform
        Relation::Base.new self, ':WAVEFORM', {'data' => ONE_ZERO, 'points' => {'mode' => ZERO, 'mode=' => ONE}}
      end
      # @endgroup

      # @group Logic Analyzer Commands
      def group(n)
        raise ArgumentError 'group must be 1 or 2' unless n == 1 || n == 2
        Relation::Group.new self, n
      end

      def logic_analyzer
        Relation::Base.new self, ':la', {
          'sdisplay' => ZERO,
          'threshold' => ZERO,
          'position' => {'reset' => ZERO},
          'group1' => {'size' => ZERO},
          'group2' => {'size' => ZERO},
          'sdisplay=' => ONE,
          'threshold=' => ONE,
        }
      end

      def digital(m)
        raise ArgumentError 'digital channel must be 0..15' unless (m && m >=0 && m < 16)
        Relation::Base.new self, ":digital#{m}", {
          'turn' => ZERO,
          'turn=' => ONE,
          'position' => ZERO,
          'position=' => ONE
        }
      end
      # @endgroup

      # @group Key Commands
      def key
        Relation::Key.new self
      end
      # @endgroup

      # @group Other Commands
      def counter
        Relation::Base.new self, ":COUNTER", {'value' => ZERO, 'enable' => ZERO, 'enable=' => ONE}
      end

      def beep
        Relation::Base.new self, ':beep', {'enable' => ZERO, 'enable=' => ONE, 'action' => ZERO}
      end
      # @endgroup

      def connected?; !!@session.connected?; end
    end
  end
end

require 'oscope/relation'
