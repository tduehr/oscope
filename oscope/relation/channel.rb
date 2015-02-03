class Oscope
  module Relation
    class Channel < Base
      # ZERO = [0]
      # ONE = [1]
      # ONE_ZERO = [0,1]
      
      def initialize scope, command, commands, chan, chan_subcomm = nil
        super scope, command, commands
        @channel_commands = chan_subcomm || {
          'acquire' => {'sampling_rate' => ZERO, 'sampling_rate=' => ONE},
          'trigger' => {
            'edge' => {'source' => ZERO},
            'slope' => {'source' => ZERO},
            'video' => {'source' => ZERO},
            'pulse' => {'source' => ZERO},
            'duration' => {'source' => ZERO},
            'pattern' => {'source' => ZERO},
            'alternation' => {'source' => ZERO}
          },
          'waveform' => {'data' => ZERO}
        }
        
        @channel = chan
      end

      def subcommands
        @subcommands + @channel_commands
      end
    end
  end
end