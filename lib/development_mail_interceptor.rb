class DevelopmentMailInterceptor
  def self.delivering_email(message)
    message.subject = "YACHT-DEV to: #{message.to}, subj: #{message.subject}"
    message.to = "christian.wittekindt@physchem.uni-freiburg.de"
  end
end
