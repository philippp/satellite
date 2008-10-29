# Simple tracking of imports via import records.
# We create an ImportRecord for the object and service on first import. 
# We report that the object has been imported, allowing for easy tracking
# of imports independent of objects.
#--
# Usage example: 
# importer = Importer.new(Photo, "flickr", build)
# unless importer.has_imported?("flickrid_23423234324434")
#   new_photo = importer.import(new_photo_params)
# end
#++
class  Importer

  attr_reader :imported_class
  attr_reader :imported_service
  
  # Register an activerecord class and source for import
  def initialize( imported_class, imported_service, import_message = "create" ) 
    @imported_class = imported_class
    @imported_service = imported_service
    @import_message = import_message
  end

  def has_imported?(sourcekey)
    return !find_import_record(sourcekey).nil?
  end
  
  def find_imported(sourcekey)
    ir = find_import_record(sourcekey)
    return @imported_class.find_by_id(ir.import_id)
  end

  def import(sourcekey, *args)
    new_imported_object = create_instance *args
    create_import_record( sourcekey, new_imported_object)
    new_imported_object
  end
  
  #########
  protected
  #########
  
  def create_import_record(sourcekey, new_imported_object)
    ImportRecord.create(:source => @imported_service,
                        :sourcekey => sourcekey,
                        :import_type => new_imported_object.class.to_s.upcase,
                        :import_id => new_imported_object.id)
  end
  
  def find_import_record(sourcekey)
    return ImportRecord.find(:first, 
                             :conditions => { 
                               :source => @imported_service, 
                               :sourcekey => sourcekey, 
                               :import_type => @imported_class.to_s.upcase
                             })
  end
  
  def create_instance( *args )
    @imported_class.send( @import_message, *args)
  end
  
  
  
end
