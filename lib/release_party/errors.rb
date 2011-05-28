require 'net/smtp'

SMTP_SERVER_ERRORS = [TimeoutError,
                      IOError,
                      EOFError,
                      Errno::EINVAL,
                      Errno::ECONNRESET,
                      Errno::ECONNREFUSED,
                      Net::SMTPFatalError,
                      Net::SMTPUnknownError,
                      Net::SMTPServerBusy,
                      Net::SMTPAuthenticationError]

