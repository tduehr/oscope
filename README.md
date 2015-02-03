oscope
======

SCPI driver for VISA instruments. Currently, only the ds1102d oscilloscope is defined. All other SCPI instruments should work if oscope is provided the commands.

### Example

```ruby
require 'oscope/rigol/ds1102d'

scope = Oscope::Rigol::Ds1102d.new
scope.open(scope.session.find_resources('USB*').first)
# get timebase settings
scope.timebase.scale.to_f
scope.timebase.offset.to_f

# get channel settings
scope.channel(1).scale.to_f
scope.channel(1).offset.to_f
scope.channel(2).scale.to_f
scope.channel(2).offset.to_f
scope.acquire.sampling_rate('chan2').to_f

# get channel waveforms
scope.waveform.data 'chan2'
scope.waveform.data 'chan1'
scope.waveform.data 'digital'
```

### Contributing to oscope


* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

#### Copyright

Copyright (c) 2015 tduehr. See LICENSE for
further details.

