# Root ProjectRazor namespace
module ProjectRazor
  module ModelTemplate
    # Root Model object
    # @abstract
    class VMwareESXi5DHCP < ProjectRazor::ModelTemplate::VMwareESXi

      def initialize(hash)
        super(hash)
        # Static config
        @hidden = false
        @name = "vmware_esxi_5_dhcp"
        @description = "VMware ESXi 5 Deployment (No IP Pool, no broker)"
        @osversion = "5_dhcp"
        # Metadata vars
        @hostname_prefix         = nil
        @broker_plugin = false
        @req_metadata_hash       = {
            "@esx_license"             => { :default     => "",
                                            :example     => "AAAAA-BBBBB-CCCCC-DDDDD-EEEEE",
                                            :validation  => '^[A-Z\d]{5}-[A-Z\d]{5}-[A-Z\d]{5}-[A-Z\d]{5}-[A-Z\d]{5}$',
                                            :required    => true,
                                            :description => "ESX License Key" },
            "@root_password"           => { :default     => "test1234",
                                            :example     => "P@ssword!",
                                            :validation  => '^[\S]{8,}',
                                            :required    => true,
                                            :description => "root password (> 8 characters)" },
            "@hostname_prefix"         => { :default     => "",
                                            :example     => "esxi",
                                            :validation  => '^[A-Za-z\d-]{3,}$',
                                            :required    => true,
                                            :description => "Prefix for naming node" },
            "@ntpserver"               => { :default     => "",
                                            :example     => "ntp.razor.example.local",
                                            :validation  => '^[\w.]{3,}$',
                                            :required    => true,
                                            :description => "NTP server for node" }
        }
        from_hash(hash) unless hash == nil
      end

      def node_ip_address
        false
      end

      def broker_proxy_handoff
        false
      end

      def postinstall
        @arg = @args_array.shift
        case @arg
          when "end"
            fsm_action(:postinstall_end, :postinstall)
            "ok"
          when "debug"
            "postinstall: debug"
          else
            "error"
        end
      end

    end
  end
end
