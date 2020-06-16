# Rails view helper for rendering Blocky content inside view templates.
module BlockyHelper
  # Render a Blocky content block with the given unique key. If a block is given, the
  # content inside the block will be saved if it doesn't already exist for the given key.
  # @param content_key [Symbol] The key should describe the content
  def blocky(content_key, options = {}, &block)

    multiple = options[:multiple] ? true : false

    content_block = Blocky::ContentBlock.where(content_key: content_key).first_or_initialize

    if content_block.new_record?
      content_block.content = capture(&block) if block_given?
      content_block.multiple = multiple
      content_block.save
    elsif multiple
      content_block_multiple = true
      content_block .multiple = multiple
      content_block.save
      content_block = Blocky::ContentBlock.where(content_key: content_key)
    else
      content_block .multiple = multiple
      content_block.save
      Blocky::ContentBlock.where(content_key: content_key).where.not(id: content_block.id).delete_all
    end

    if try(:current_admin_user)
      if content_block_multiple
        content_arr = ""
        content_block.active.order(:order).each do |block|
          edit_text  = "Edit"
          edit_text += '<span style="font-weight: normal; margin-left: 0.5em;">'
          edit_text += block.display_name
          edit_text += "</span>"
          content_arr += raw("#{link_to(raw(edit_text), edit_admin_content_block_path(block), style: edit_link_style)}#{block.content}")
        end
        raw(content_arr)
      else
        edit_text  = "Edit"
        edit_text += '<span style="font-weight: normal; margin-left: 0.5em;">'
        edit_text += content_block.display_name
        edit_text += "</span>"
        raw("#{link_to(raw(edit_text), edit_admin_content_block_path(content_block), style: edit_link_style)}#{content_block.content}")
      end
    else
      if content_block_multiple
        content_arr = ""
        content_block.active.order(:order).each do |block|
          Rails.cache.fetch(block, skip_digest: true) do
            content_arr += raw(block.content)
          end
        end
        raw(content_arr)
      else
        Rails.cache.fetch(content_block, skip_digest: true) do
          raw(content_block.content)
        end
      end
    end
  end

private

  def edit_link_style
    style  = "background-color: rgba(0, 0, 0, 0.5);"
    style += "border-radius: 2px;"
    style += "color: #fff;"
    style += "display: block;"
    style += "font-size: 12px !important;"
    style += "font-weight: bold;"
    style += "padding: 0.5em 1em;"
    style += "position: absolute;"
    style += "text-decoration: none;"
    style
  end
end
