#Added the google map with geocoder gem and gmap4rails.
geocoded_by :full_address 
after_validation :geocode, if: ->(obj){ obj.address.present? and obj.address_changed? }

def full_address
  [country,name,address,city,zip].compact.join(",")
end

#select option in storefinder template
<%= tabs do |c| %>
  <% c.tab 'Local Stores' do %>
      <div class="storefinder_map">
        <%= select_tag "page_type", options_for_select(%w{de at ch fr nl be it es fin gr pl ua jp au sk gb}.collect{ |c, i| ["#{I18n.t(c)}", c]}), id: "country_selection" %></br><hr>
        <%= select_tag "page_type", options_for_select(@countries), id: "country_selection" %></br><hr>
        <div id="stores">
          <%= render partial: 'storefinder', locals: { stores: @stores } %>
        </div>
      </div>
  <% end %>
<% end %>

#Partial with script
<div class="tab-content">
  <div class="row">
    <div class="col-md-12"></div>
  </div>
  <div class="row">
    <div class="col-md-9 col-sm-9 col-xs-12">
      <div class="map-holder">
        <div style='width: 100%;'>
          <div id="map"></div>
        </div>
      </div>
    </div>
    <div class="col-md-3 col-sm-3 col-xs-12">
      <div class="store-holder">
        <% stores.each do |store| %>
          <div class="row">
              <div class="col-md-12 col-sm-12 col-xs-12">
                  <div class="store-item" country="<%= store.country %>" id="store_<%= store.id %>">
                    <strong>
                      <%= store.name %>
                    </strong>
                    <br/>
                    <%= store.address %>
                  </div>
              </div>
          </div>
        <% end %>  
      </div>
    </div>
  </div>
</div>


<script>

Gmaps.store = {}

handler = Gmaps.build('Google')
 
handler.buildMap({
    provider: {
      zoom: 6,
      center: new google.maps.LatLng(52.5019, 13.3655),
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      styles: mapStyle  
    },
    internal: {
      id: 'map'
    }
  },
  function(){
    markers = <%= raw @sthash.to_json %>

    Gmaps.store.markers = markers.map(function(m) {
      marker = handler.addMarker(m);
      marker.serviceObject.set('id', m.id);
      return marker;
    });
    markers = handler.addMarkers(<%= raw @sthash.to_json %>);
    handler.bounds.extendWith(markers);
    handler.fitMapToBounds();
    handler.getMap().setZoom(6)
  }
);

openMarkerInfo = function(id) {
  $.each(Gmaps.store.markers, function() {
    if (this.serviceObject.id == id) {
      console.log("id" + id)
      google.maps.event.trigger(this.getServiceObject(), 'click')
    }
  });
}


$(".store-item").on("mouseover", function(){
  openMarkerInfo(this.id);
    $(this).addClass("active-item");
    $(".store-item").on("mouseout", function(){
        $(this).removeClass("active-item");
    });
});
</script>