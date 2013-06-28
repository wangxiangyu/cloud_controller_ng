require 'services/api'
require 'cloud_controller/api/service_validator'

module VCAP::CloudController
  rest_controller :ServiceBinding do
    permissions_required do
      full Permissions::CFAdmin
      read Permissions::OrgManager
      create Permissions::SpaceDeveloper
      read   Permissions::SpaceDeveloper
      delete Permissions::SpaceDeveloper
      read Permissions::SpaceAuditor
    end

    define_attributes do
      to_one    :app
      to_one    :service_instance
    end

    query_parameters :app_guid, :service_instance_guid

    def self.translate_validation_exception(e, attributes)
      unique_errors = e.errors.on([:app_id, :service_instance_id])
      if unique_errors && unique_errors.include?(:unique)
        Errors::ServiceBindingAppServiceTaken.new(
          "#{attributes["app_guid"]} #{attributes["service_instance_guid"]}")
      else
        Errors::ServiceBindingInvalid.new(e.errors.full_messages)
      end
    end

    post "/v2/service_bindings", :create

    def create
      request_attrs = self.class::CreateMessage.decode(body)
      body.rewind
      instance = Models::ServiceInstance.find(guid: request_attrs.service_instance_guid)

      if instance.is_a? Models::ManagedServiceInstance
        return super
      end

      app = Models::App.find(guid: request_attrs.app_guid)

      app.add_provided_service_instance(instance)
      HTTP::NO_CONTENT
    end
  end
end
