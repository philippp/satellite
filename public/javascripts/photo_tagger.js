/**
 * Creates a tagger for a single image on a page. Specify the image element id and form element id.
 * The form must contain hidden inputs named x and y. The relative location of the click will be written
 * to these hidden inputs.
 * We render the tag and give them the id pt-tag-<label_id>, and class pt-tag.
 */
var PhotoTagger = Class.create(
  {

    /**
     * Positions the labels on mouseover
     * Shows all labels
     */
    onMouseover: function(e){

      for (var i=0; i < this.photoTagger.tags.length; i++) {
	tag = this.photoTagger.tags[i];
	//  /100 for percent conversion
	style = "left:"+ this.width * (tag.x / 100) +"px; top:"+ this.height * (tag.y / 100) +"px; display:block;";
	$("pt-tag-" + tag.id).setStyle(style);
	a = 1;
      }

      $$('div.pt-tag').each(Element.show);
    },

    /**
     * Hide labels on mouseout
     */
    onMouseout : function(e){
      if(PhotoTagger.onMouseoutCheck(this, e)){
	$$('div.pt-tag').each(Element.hide);
      }
    },


    onClick : function(e){

      picture_location = PhotoTagger.find_element_pos(this);
      mouse_location = PhotoTagger.find_mouse_pos(e);

      // X and Y positions of the label to be created
      tag_x = mouse_location[0] - picture_location[0];
      tag_y = mouse_location[1] - picture_location[1];

      // label has to be on picture, min 5 px
      if( tag_x < 5) tag_x = 5;
      if( tag_y < 5) tag_y = 5;

      // position for box representing what you are labeling
      abs_x = mouse_location[0] - picture_location[0];
      abs_y = mouse_location[1] - picture_location[1];

      // box pushed down and right if too far up or left
      if( abs_x < 50) abs_x = 50;
      if( abs_y < 50) abs_y = 50;

      // form location
      x_pointer_offset = -40;
      y_pointer_offset = 45;

      form_x = abs_x + x_pointer_offset;
      form_y = abs_y + y_pointer_offset; // Relative to containing element in jQ? (was click_abs_y_loc + y_pointer_offset);

      frame_height = frame_width = 80;
      frame_x = abs_x - (frame_width/2);
      frame_y = abs_y - (frame_height/2);

      frame_style = "position:absolute; top:"+ (frame_y - 4) +"px; left:"+ frame_x +"px; border:0.3em solid #cccccc; width:7em; height:6em;z-index:10;color:black;display:block";

      style = "position: absolute;color:black; top:" + form_y + "px; left:" + form_x + "px; background-color:white; border: 0.3em solid #cccccc; padding:0.5em;";

      $('pt-taggerframe').setStyle(frame_style);
      $('pt-taggerframe').show();

      $(this.pt_form_id).setStyle(style);
      $(this.pt_form_id).show();

      PhotoTagger.render_tagger(this);
    },

    init_labeler : function(){
    },

    /*
     * Set up tagging events for the specified image.
     */
    initialize: function(image_id, form_id, tags_arr) {
      $(image_id).style.cursor = "crosshair";
      $(image_id).photoTagger = this;
      $(image_id).parentNode.appendChild($(form_id)); //needs to be adjacent to img element
      $(image_id).pt_form_id = form_id;

      this.tags = tags_arr;

      $$('img#'+image_id).invoke('observe','mouseover', this.onMouseover);
      $$('photo-tagger-label').invoke('observe','mouseover', this.onMouseover);
      $$('img#'+image_id).invoke('observe', 'click', this.onClick);
      $$('img#'+image_id).invoke('observe', 'mouseout', this.onMouseout);


      taggerframe = new Element('div',{'id' : 'pt-taggerframe'})
      $(image_id).parentNode.appendChild(taggerframe);


      //create tags

      for (var i=0; i < this.tags.length; i++) {
	tag = this.tags[i];
	tag_elem = new Element('div',{"id": "pt-tag-"+tag.id, "class": "pt-tag", "style":"display:none;"});
	tag_elem.update(tag.text);
	$(image_id).parentNode.appendChild(tag_elem);
      }
    },

    tags : []


});



PhotoTagger.render_tagger = function(img_element){

	/**
      $('image_x').value = img_element.width; //x_loc;
      $('image_y').value = img_element.height; //y_loc;

      $('x').value = label_x; //x_loc;
      $('y').value = label_y; //y_loc;
      $('friend_name_label_<%= @asset.id %>').value = '';
      $('friend_name_label_<%= @asset.id %>').focus();
*/
};


/**
 * Quirksmode helper to get element position
 * relattive to the top left corner of the document
 */
PhotoTagger.find_element_pos = function(obj) {
  var curleft = 0;
  var curtop = 0;
  if (obj.offsetParent) {
    do {
      curleft += obj.offsetLeft;
      curtop += obj.offsetTop;
      } while((obj = obj.offsetParent)); //yes, while it's not undefined
    }
    // mouse position relative to the document's top left corner
    return [curleft,curtop];
};

/**
 * Quirksmode helper to get mouse event position
 * relative to the top left corner of the document
 */
 PhotoTagger.find_mouse_pos = function(e) {
   var posx = 0;
   var posy = 0;
   if (!e) var e = window.event;

   if (e.pageX || e.pageY){
     posx = e.pageX;
     posy = e.pageY;
   }else if (e.clientX || e.clientY){
     posx = e.clientX + document.body.scrollLeft
       + document.documentElement.scrollLeft;
     posy = e.clientY + document.body.scrollTop
       + document.documentElement.scrollTop;
   }
   return [posx, posy];
 };


    /**
     * Are we really out of the photo or on a label?
     */
PhotoTagger.onMouseoutCheck = function(element, event){
  picture_location = PhotoTagger.find_element_pos(element);
  mouse_location = PhotoTagger.find_mouse_pos(event);

  if( mouse_location[0] < picture_location[0] ){
    return true;
  }
  if( mouse_location[1] < picture_location[1]){
    return true;
  }
  if( mouse_location[1] > picture_location[1]+element.height){
    return true;
  }
  if( mouse_location[0] > picture_location[0]+element.width){
    return true;
  }
    return false;
};
