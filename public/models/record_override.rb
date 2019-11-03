class Record

  include ManipulateNode
  include JsonHelper
  include RecordHelper
  include PrefixHelper

  def parse_container_display(opts = {})
    summary = opts.fetch(:summary, false)
    include_uri = opts.fetch(:include_uri, false)
    containers = []

    if !json['instances'].blank? && json['instances'].kind_of?(Array)
      json['instances'].each do |inst|
        sub_container = inst.fetch('sub_container', nil)

        next if sub_container.nil?

        container_display_string = parse_sub_container_display_string(sub_container, inst, opts)
        if include_uri && top_container_uri = sub_container.dig('top_container', 'ref')
          containers << {
            'title' => container_display_string,
            'uri' => top_container_uri
          }
        else
          containers << container_display_string
        end
      end
      #Moved this out of the instance loop to prevent the loop from stopping once
      #the container count is greater than 1; added condition so that if the length
      #of the container list is greater than 1 but less than 4 it returns a string
      #representation of the container titles - also changed the '_present_list' .erb
      #file that renders the container list to skip strings so that it will display 
      #properly in the badge; changed 'multiple_containers' locale to accept the
      #number of containers as a parameter, and added the elsif statement so that if
      #the number of containers is 4 or more it updates the multiple containers locale. 
      #Question: should this be moved to the if summary block below?
      if summary && containers.length > 1 && containers.length < 4
        return containers.join(', ')
      elsif summary && containers.length >= 4
        return I18n.t('multiple_containers', :container_len => containers.length)
      end
    end

    if summary
      containers.empty? ? nil : containers[0]
    else
      containers
    end
  end

end