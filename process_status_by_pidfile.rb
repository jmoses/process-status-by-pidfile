class ProcessStatusByPidfile < Scout::Plugin

  OPTIONS = <<-EOS
    pidfile:
      default: /path/to/pidfile
  EOS

  def build_report
    unless File.exists?( option(:pidfile) ) && File.readable_real?( option(:pidfile) )
      return error("Can't find pidfile, or it's not readable by us.")
    end

    begin
      Process.getpgid( File.read( option(:pidfile) ).strip.to_i )
      remember(:last_status => :running)
      report(:status => "running")
    rescue Errno::ESRCH
      report(:status => "not found")
      if( memory(:last_status) == :running )
        alert("PID not found!")
      end
      remember(:last_status, :not_found)
    end
  end
end
