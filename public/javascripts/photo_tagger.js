/**
 * Create a tagging interface for a specified image.
 * Example:
 * ptTags = [{"y": 78, "name": "words", "friend_id": 3, "id": 4, "x": 23}]
 * var photo_tagger = new PhotoTagger("photo","tag_form",ptTags);
 *
 */
var PhotoTagger = Class.create(
  {

    /**
     * Set up tagging events for the specified image.
     *
     * The PhotoTagger renders all specified tags for the image,
     * and shows an implementation-specific form for new tag creation.
     * If the implementation-specific form contains fields named "x" and "y",
     * these fields are updated with the x and y tag locations.
     *
     *
     * @constructor
     * @param {string} image_id Element ID of targeted image.
     * @param {string} form_id Element ID of implementation-specific form for server-side tag creation.
     * @param {array} tags_arr JSON array of existing tags to display
     */
    initialize: function(image_id, form_id, tags_arr) {
      $(image_id).style.cursor = "crosshair";
      $(image_id).photoTagger = this;
      $(image_id).parentNode.appendChild($(form_id)); //needs to be adjacent to img element
      $(image_id).photoTagger.pt_form_id = form_id;

      this.image_id = image_id;
      this.tags = tags_arr;

      $$('img#'+image_id).invoke('observe','mouseover', PhotoTagger.onMouseover);
      $$('photo-tagger-label').invoke('observe','mouseover', PhotoTagger.onMouseover);
      $$('img#'+image_id).invoke('observe', 'click', PhotoTagger.onClick);
      $$('img#'+image_id).invoke('observe', 'mouseout', PhotoTagger.onMouseout);


      taggerframe = new Element('div',{'id' : 'pt-taggerframe'})
      $(image_id).parentNode.appendChild(taggerframe);

      this.render_tags();
    },

    /**
     * Hides form and tagging frame
     */
    cancelForm : function(){
      new Effect.Fade(this.pt_form_id);
      new Effect.Fade("pt-taggerframe");
    },

    show_tags: function(){
      for (var i=0; i < this.tags.length; i++) {
	tag = this.tags[i];
	//  /100 for percent conversion
	style = "left:"+ $(this.image_id).width * (tag.x / 100) +"px; top:"+ $(this.image_id).height * (tag.y / 100) +"px; display:block;";
	$("pt-tag-" + tag.id).setStyle(style);
      }
      $$('div.pt-tag').each(Element.show);
    },

    hide_tags: function(){
      $$('div.pt-tag').each(Element.hide);
    },

    /**
     * Set a new tag array and render all new tags as elements.
     * @param {array} tag_array Array of JSON tag objects
     */
    update_tags : function(tag_array){
      this.tags = tag_array;
      this.render_tags();
    },

    /**
     * Ensure that all tags are rendered to elements.
     * @private
     */
    render_tags : function(){
      for (var i=0; i < this.tags.length; i++) {
	tag = this.tags[i];
	if( $("pt-tag-"+tag.id) == null ){
	  tag_elem = new Element('div',{"id": "pt-tag-"+tag.id, "class": "pt-tag", "style":"display:none;"});
	  tag_elem.update(tag.name);
	  $(this.image_id).parentNode.appendChild(tag_elem);
	}
      }

    },

    tags : []


});


//
// STATIC FUNCTIONS
//

/**
 * Called on targeted image: Positions the labels on mouseover
 * Shows all labels
 */
PhotoTagger.onMouseover = function(e){
  this.photoTagger.show_tags();
};

/**
 * Called on targeted image: Hide labels on mouseout
 */
PhotoTagger.onMouseout = function(e){
  if(PhotoTagger.onMouseoutCheck(this, e)){
    this.photoTagger.hide_tags();
  }
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


/**
 * Called on targeted image:
 */
PhotoTagger.onClick = function(e){
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
  y_pointer_offset = 38;

  form_x = abs_x + x_pointer_offset;
  form_y = abs_y + y_pointer_offset; // Relative to containing element in jQ? (was click_abs_y_loc + y_pointer_offset);

  frame_height = frame_width = 80;
  frame_x = abs_x - (frame_width/2);
  frame_y = abs_y - (frame_height/2);

  frame_style = "position:absolute; top:"+ (frame_y - 4) +"px; left:"+ frame_x +"px; border:0.3em solid #cccccc; width:7em; height:6em;z-index:10;color:black;display:block; z-index:10001;";

  style = "position: absolute;color:black; top:" + form_y + "px; left:" + form_x + "px; background-color:white; border: 0.3em solid #cccccc; padding:0.5em; z-index:10001;";

  $('pt-taggerframe').setStyle(frame_style);
  $('pt-taggerframe').show();

  $('x').value = parseInt((tag_x/this.width)*100);
  $('y').value = parseInt((tag_y/this.height)*100);

  $('friend_name').value = "";
  $('create-tag-response').update("");

  $(this.photoTagger.pt_form_id).setStyle(style);
  $(this.photoTagger.pt_form_id).show();
  $('friend_name').focus();
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


