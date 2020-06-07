if defined?(ActiveAdmin)
  ActiveAdmin.register Blocky::ContentBlock, as: "ContentBlock" do
    config.batch_actions = false
    config.sort_order = "description_asc"

    controller do
      resources_configuration[:self][:instance_name] = "content_block"
    end

    permit_params :content, :content_key, :description

    actions :all, except: [:destroy, :new]

    filter :description
    filter :content_key

    index do
      selectable_column
      column "Content Block", :description, sortable: :description do |content_block|
        a content_block.description.blank? ? "< Please set the description >" : content_block.description, href: edit_admin_content_block_path(content_block)
        br
        small content_block.content_key
      end
      column :created_at
      column :updated_at
      actions
    end

    form do |f|
      f.inputs "Details" do
        f.input :description
        f.input :content_key if resource.new_record?
        f.input :content
      end
      actions
    end

    show do
      attributes_table do
        row :description
        row :content_key
        row :created_at
        row :updated_at
        row :content do |content_block|
          raw content_block.content
        end
      end
      active_admin_comments
    end
  end
end
