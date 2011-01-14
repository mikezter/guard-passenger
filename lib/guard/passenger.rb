require 'guard'
require 'guard/guard'
require 'rubygems'

module Guard
  class Passenger < Guard

    autoload :Runner, 'guard/passenger/runner'
    autoload :Pinger, 'guard/passenger/pinger'

    attr_reader :port, :env, :ping, :args

    def standalone?
      @standalone
    end

    # =================
    # = Guard methods =
    # =================

    def initialize(watchers = [], options = {})
      super
      @standalone = options[:standalone].nil? ? true : options[:standalone]
      @port       = options[:port] || 3000
      @env        = options[:env] || 'development'
      @args       = options[:args] || ''
      ping_opt = unless options[:touch].nil?
        UI.info "Warning: The :touch option has been replaced by the :ping option, usage is still the same."
        options[:touch]
      else
        options[:ping]
      end
      @ping = ping_opt.eql?(true) ? '/' : ping_opt
    end

    # Call once when guard starts
    def start
      UI.info 'Guard::Passenger is running!'
      standalone? ? Runner.start_passenger(port, env, args) : true
    end

    # Call with Ctrl-C signal (when Guard quit)
    def stop
      UI.info 'Stopping Passenger...'
      standalone? ? Runner.stop_passenger(port) : true
    end

    # Call with Ctrl-Z signal
    def reload
      restart_and_ping
    end

    # Call on file(s) modifications
    def run_on_change(paths = {})
      restart_and_ping
    end

    private

    def restart_and_ping
      UI.info 'Restarting Passenger...'
      restarted = Runner.restart_passenger
      Pinger.ping('localhost', port, ping) if ping
      restarted
    end

  end
end