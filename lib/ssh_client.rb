require 'net/ssh'

class SSHClient

  def initialize(host, user, password)
    @connection = Net::SSH.start(host, user, :password => password)
    @log = Logger.new(STDOUT)
  end

  def exec cmd
    @log.info cmd
    ssh_data = nil
    @connection.open_channel do |channel|
      channel.exec(cmd) do |ch, success|
        unless success
          @log.error "Couldn't execute #{cmd}"
          raise ::RuntimeError, "Couldn't execute #{cmd}"
        end

        ch.on_request "exit-status" do |_, data|
          raise ::RuntimeError, ssh_data if data.read_long > 0
        end

        ch.on_data do |_, data| # stdout
          ssh_data = data
        end
      end
    end
    @connection.loop
    @log.info ssh_data
    ssh_data
  end
end