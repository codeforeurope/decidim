# frozen_string_literal: true

module Decidim
  # A heper to expose an easy way to add authorization forms in a view.
  module DecidimFormHelper
    # A custom form for that injects client side validations with Abide.
    #
    # record - The object to build the form for.
    # options - A Hash of options to pass to the form builder.
    # &block - The block to execute as content of the form.
    #
    # Returns a String.
    def decidim_form_for(record, options = {}, &block)
      options[:data] ||= {}
      options[:data].update(abide: true, "live-validate" => true, "validate-on-blur" => true)

      options[:html] ||= {}
      options[:html].update(novalidate: true)

      form_for(record, options, &block)
    end

    # A custom helper to include an editor field without requiring a form object
    #
    # name - The input name
    # value - The input value
    # options - The set of options to send to the field
    #           :label   - The Boolean value to create or not the input label (optional) (default: true)
    #           :toolbar - The String value to configure WYSIWYG toolbar. It should be 'basic' or
    #                      or 'full' (optional) (default: 'basic')
    #           :lines   - The Integer to indicate how many lines should editor have (optional)
    #
    # Returns a rich editor to be included in a html template.
    def editor_field_tag(name, value, options = {})
      options[:toolbar] ||= "basic"
      options[:lines] ||= 10

      content_tag(:div, class: "editor") do
        template = ""
        template += label_tag(name, options[:label]) if options[:label] != false
        template += hidden_field_tag(name, value, options)
        template += content_tag(:div, nil, class: "editor-container", data: {
                                  toolbar: options[:toolbar]
                                }, style: "height: #{options[:lines]}rem")
        template.html_safe
      end
    end

    # A custom helper to include a translated field without requiring a form object.
    #
    # type        - The type of the translated input field.
    # object_name - The object name used to identify the Foundation tabs.
    # name        - The name of the input which will be suffixed with the corresponding locales.
    # value       - A hash containing the value for each locale.
    # options     - An optional hash of options.
    #             * enable_tabs: Adds the data-tabs attribute so Foundation picks up automatically.
    #             * tabs_id: The id to identify the Foundation tabs element.
    #             * label: The label used for the field.
    #
    # Returns a Foundation tabs element with the translated input field.
    def translated_field_tag(type, object_name, name, value = {}, options = {})
      locales = available_locales

      field_label = label_tag(name, options[:label])

      if locales.count == 1
        field_name = "#{name}_#{locales.first.to_s.gsub("-", "__")}"
        field_input = send(
          type,
          "#{object_name}[#{field_name}]",
          value[locales.first.to_s]
        )

        return safe_join [field_label, field_input]
      end

      tabs_id = options[:tabs_id] || "#{object_name}-#{name}-tabs"
      enabled_tabs = options[:enable_tabs].nil? ? true : options[:enable_tabs]
      tabs_panels_data = enabled_tabs ? { tabs: true } : {}

      label_tabs = content_tag(:div, class: "label--tabs") do
        tabs_panels = "".html_safe
        if options[:label] != false
          tabs_panels = content_tag(:ul, class: "tabs tabs--lang", id: tabs_id, data: tabs_panels_data) do
            locales.each_with_index.inject("".html_safe) do |string, (locale, index)|
              string + content_tag(:li, class: tab_element_class_for("title", index)) do
                title = I18n.with_locale(locale) { I18n.t("name", scope: "locale") }
                element_class = nil
                element_class = "is-tab-error" if form_field_has_error?(options[:object], name_with_locale(name, locale))
                tab_content_id = "#{tabs_id}-#{name}-panel-#{index}"
                content_tag(:a, title, href: "##{tab_content_id}", class: element_class)
              end
            end
          end
        end

        safe_join [field_label, tabs_panels]
      end

      tabs_content = content_tag(:div, class: "tabs-content", data: { tabs_content: tabs_id }) do
        locales.each_with_index.inject("".html_safe) do |string, (locale, index)|
          tab_content_id = "#{tabs_id}-#{name}-panel-#{index}"
          string + content_tag(:div, class: tab_element_class_for("panel", index), id: tab_content_id) do
            send(type, "#{object_name}[#{name_with_locale(name, locale)}]", value[locale.to_s], options.merge(id: "#{tabs_id}_#{name}_#{locale}", label: false))
          end
        end
      end

      safe_join [label_tabs, tabs_content]
    end

    # Helper method used by `translated_field_tag`
    def tab_element_class_for(type, index)
      element_class = "tabs-#{type}"
      element_class += " is-active" if index.zero?
      element_class
    end

    # Helper method used by `translated_field_tag`
    def name_with_locale(name, locale)
      "#{name}_#{locale.to_s.gsub("-", "__")}"
    end

    def form_field_has_error?(object, attribute)
      object.respond_to?(:errors) && object.errors[attribute].present?
    end

    # Helper method that generates the URL of a participatory space with a
    # span surrounding the space slug. This is only intended to be used in
    # help text for the slug input, so that we can update the span contents
    # via JS with the input value.
    #
    # space_name - the name, in plural, of the space (eg. "processes" or "assemblies")
    # value - the initial value of the slug field, so  that edit forms have a value
    #
    # Returns an HTML-safe String.
    def decidim_form_slug_url(space_name, value = "")
      content_tag(:span, class: "slug-url") do
        [
          request.protocol,
          request.host_with_port,
          "/",
          space_name,
          "/"
        ].join("").html_safe +
          content_tag(:span, value, class: "slug-url-value")
      end
    end
  end
end
