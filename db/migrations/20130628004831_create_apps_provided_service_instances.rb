Sequel.migration do
  change do
    create_table(:apps_provided_service_instances) do
      primary_key :id
      Integer :app_id, null:false
      Integer :provided_service_instance_id, null:false
      foreign_key [:app_id], :apps, name: :fk_apps_provided_service_instances_app_id
      foreign_key [:provided_service_instance_id], :service_instances, name: :fk_apps_provided_service_instances_provided_service_instance_id

      index [:app_id, :provided_service_instance_id], unique:true
    end
  end
end
