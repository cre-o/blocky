if defined?(ActiveAdmin)
  ActiveAdmin.register Blocky::ContentBlock, as: 'ContentBlock' do
    config.batch_actions = false
    config.sort_order = 'description_asc'

    controller do
      resources_configuration[:self][:instance_name] = 'content_block'

      def scoped_collection
        if ['index'].include?(params[:action])
          arr = Blocky::ContentBlock.select('distinct on (content_key) *')
          super.where(id: arr.map(&:id))
        else
          super
        end
      end
    end

    permit_params :content, :content_key, :description, :multiple, :order

    actions :all

    filter :description
    filter :content_key

    index do
      index_column
      column 'Content Block', &:content_key
      column 'Number of items' do |content_block|
        Blocky::ContentBlock.where(content_key: content_block.content_key).count
      end
      column :multiple
      actions defaults: false do |content_block|
        link_to 'View All', admin_content_keys_path(content_key: content_block.content_key), class: 'member_link'
      end
    end

    form do |f|
      if f.object.new_record?
        f.object.multiple = true
      end
      f.inputs 'Details' do
        f.input :multiple, as: :hidden
        f.input :content_key, as: :select, collection: Blocky::ContentBlock.select('distinct on (content_key) *').select{ |content_block| content_block.multiple == true }.map { |content_block| [content_block.content_key, content_block.content_key] } if resource.new_record?
        f.input :order
        f.input :description
        f.input :content
      end
      actions
    end

    show do
      attributes_table do
        row :content_key
        row :multiple
        row :order
        row :description
        row :content do |content_block|
          raw content_block.content
        end
        row :created_at
        row :updated_at
      end
    end
  end

  ActiveAdmin.register Blocky::ContentBlock, as: 'ContentKey' do
    menu false
    config.batch_actions = false
    config.filters = false

    controller do
      def scoped_collection
        super.where(content_key: params[:content_key])
      end

      def index
        @page_title = (params[:content_key]).to_s
        super
      end

      def show
        redirect_to admin_content_block(params[:id])
      end

      def new
        redirect_to new_admin_content_block_path
      end

      def edit
        redirect_to edit_admin_content_block_path(params[:id])
      end
    end

    config.action_items[0] = ActiveAdmin::ActionItem.new only: :index do
      link_to 'New Content Block', new_admin_content_block_path
    end


    index do
      column :id
      column :content_key
      column :order
      column :description
      column :created_at
      column :updated_at
      actions defaults: false  do |item|
        links = []
        links << link_to('View', admin_content_block_path(item), class: 'member_link')
        links << link_to('Edit', edit_admin_content_block_path(item), class: 'member_link')
        links << link_to('Delete', admin_content_block_path(item), method: :delete, confirm: 'Are you sure?', class: 'member_link')
        links.join(' ').html_safe
      end
    end
  end
end
