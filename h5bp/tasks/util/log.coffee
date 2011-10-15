
winston         = require 'winston'
eyes            = require 'eyes'
levels          = winston.config.cli.levels

# setup logger
module.exports = (options) ->
  logger = new winston.Logger
    transports: [
      new winston.transports.Console({ level: options.loglevel || 'input' })
    ]

  logger.inspector = eyes.inspector
    stream: null
    styles:                 # Styles applied to stdout
      all:     null,        # Overall style applied to everything
      label:   'underline', # Inspection labels, like 'array' in `array: [1, 2, 3]`
      other:   'inverted',  # Objects which don't have a literal representation, such as functions
      key:     'grey',      # The keys in object literals, like 'a' in `{a: 1}`
      special: 'grey',      # null, undefined...
      number:  'blue',      # 0, 1, 2...
      bool:    'magenta',   # true false
      regexp:  'green'      # /\d+/

  logger.inspect = (o) ->
    result = log.inspector(o)
    log.data line for line in result.split('\n')

  logger.cli()
