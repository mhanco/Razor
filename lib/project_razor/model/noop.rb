# Root ProjectRazor namespace
module ProjectRazor
  module ModelTemplate
    # Root Model object
    # @abstract
    class Noop < ProjectRazor::ModelTemplate::Base
      include(ProjectRazor::Logging)
      attr_accessor :image_uuid
      attr_accessor :image_prefix
      def initialize(hash)
        super(hash)
        # Static config
        @hidden = false
        @template = :noop
        @name = "noop"
        @description = "Model for deploying nothing."
        # Metadata vars
        @current_state = :init
        @image_uuid = true
        @image_prefix = "os"
        @broker_plugin = false
        @final_state = :os_complete
        from_hash(hash) unless hash == nil
        @req_metadata_hash = {}
      end

      # Defines our FSM for this model
      #  For state => {action => state, ..}
      def fsm_tree
        {
          :init => {
            :mk_call        => :init,
            :boot_call      => :os_complete,
            :timeout        => :timeout_error,
            :error          => :error_catch,
            :else           => :init
          },
          :os_complete => {
            :mk_call        => :os_complete,
            :boot_call      => :os_complete,
            :else           => :os_complete,
            :reset          => :init
          },
          :timeout_error => {
            :mk_call        => :timeout_error,
            :boot_call      => :timeout_error,
            :else           => :timeout_error,
            :reset          => :init
          },
          :error_catch => {
            :mk_call        => :error_catch,
            :boot_call      => :error_catch,
            :else           => :error_catch,
            :reset          => :init
          },
        }
      end

      def mk_call(node, policy_uuid)
        super(node, policy_uuid)
        previous_state = @current_state
        fsm_action(:mk_call, :mk_call)
        case previous_state
          # We need to reboot
        when :init, :os_complete, :broker_check
          [:reboot, {}]
        when :timeout_error, :error_catch
          [:acknowledge, {}]
        else
          [:acknowledge, {}]
        end
      end

      def boot_call(node, policy_uuid)
        super(node, policy_uuid)
        previous_state = @current_state
        fsm_action(:boot_call, :boot_call)
        case previous_state
        when :init, :broker_check, :complete_no_broker
          local_boot(node)
        when :timeout_error, :error_catch
          engine = ProjectRazor::Engine.instance
          engine.default_mk_boot(node.uuid)
        else
          engine = ProjectRazor::Engine.instance
          engine.default_mk_boot(node.uuid)
        end
      end

      def local_boot(node)
        ip = "#!ipxe\n"
        ip << "echo Reached #{@label} model boot_call\n"
        ip << "echo Our state is: #{@current_state}\n"
        ip << "echo Our node UUID: #{node.uuid}\n"
        ip << "\n"
        ip << "echo Continuing local boot\n"
        ip << "sleep 3\n"
        ip << "\n"
        ip << "sanboot --no-describe --drive 0x80\n"
        ip
      end

    end
  end
end
