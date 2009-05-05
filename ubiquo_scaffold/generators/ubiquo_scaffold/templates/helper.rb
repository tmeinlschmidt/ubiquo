module Ubiquo::<%= controller_class_name %>Helper
  def <%= singular_name %>_filters_info(params)
    filters = []
    filters <<  filter_info(:string, params,
           :field => :filter_text,
           :caption => t('ubiquo.text'))

    <%- if options[:translatable] -%>
    filters << filter_info(:string, params,
           :field => :filter_locale,
           :caption => <%= model_name %>.human_attribute_name("locale"))
    <%- end -%>
    <%- if has_published_at -%>
    filters << filter_info(:date, params,
        :caption => <%= model_name %>.human_attribute_name("published_at"),
        :field => [:filter_publish_start, :filter_publish_end])
    <%- end -%>
    build_filter_info(*filters)
  end

  def <%= singular_name %>_filters(url_for_options = {})
    filters = []
    filters << render_filter(:string, url_for_options,
        :field => :filter_text,
        :caption => t('ubiquo.text'))
        
    <%- if options[:translatable] -%>
    filters << render_filter(:links, url_for_options,
        :caption => <%= model_name %>.human_attribute_name("locale"),
        :field => :filter_locale,
        :collection => Locale.active,
        :id_field => :iso_code,
        :name_field => :native_name)
    <%- end -%>
    <%- if has_published_at -%>
    filters << render_filter(:date, url_for_options,
        :caption => <%= model_name %>.human_attribute_name("published_at"),
        :field => [:filter_publish_start, :filter_publish_end])
    <%- end -%>
    filters.join
  end

  def <%= singular_name %>_list(collection, pages, options = {})
    render(:partial => "shared/ubiquo/lists/standard", :locals => {
        :name => '<%= singular_name%>',
        :headers => [<%= attributes.collect{|at| ":#{at.name}"}.join(", ") %>],
        :rows => collection.collect do |<%= singular_name%>| 
          {
            :id => <%= singular_name%>.id, 
            :columns => [
              <%- attributes.each do |at| -%>
              <%= "#{singular_name}.#{at.name}," %>
              <%- end -%>
            ],
            :actions => <%= singular_name %>_actions(<%= singular_name%>)
          }
        end,
        :pages => pages
      })
  end
    
  private
    
  def <%= singular_name %>_actions(<%= singular_name%>, options = {})
    actions = []
    actions << link_to(t("ubiquo.edit"), [:edit, :ubiquo, <%= singular_name%>])
    actions << link_to(t("ubiquo.remove"), [:ubiquo, <%= singular_name%>], 
      :confirm => t("ubiquo.<%= singular_name %>.index.confirm_removal"), :method => :delete)
    actions
  end
end
