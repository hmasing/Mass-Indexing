class IndexDatabase < ActiveRecord::Migration
  @fields_to_index = ['name', 'value', 'type', '_id', 'sku', 'is_', '_at', '_on', 'email', 
                     'postal', 'zip', 'state', 'country', 'position', 'login', 'bin', 'controller', 
                     'action', 'token', 'code', 'uuid', 'guid', 'gender', 'link']
  
  def self.up     
    ActiveRecord::Migration::say 'Setting all tables to InnoDB engine (excluding schema_info table)...'

    result = ActiveRecord::Migration::execute 'show tables'
    while table = result.fetch_row
      execute("ALTER TABLE #{table.to_s} TYPE = InnoDB") unless table.to_s == 'schema_info'
    end

    ActiveRecord::Migration::say 'Indexing all specified columns in tables...'

    result = ActiveRecord::Migration::execute 'show tables'
    while table = result.fetch_row
      next if table.to_s == 'schema_info'
      
      fields = ActiveRecord::Migration::execute "show columns from #{table}"
            
      for field in fields
        field_name = field[0]
        
        for val in @fields_to_index
          begin
            add_index table, field_name if field_name.to_s.include?(val) 
          rescue
            ActiveRecord::Migration::say "ERROR - probably a duplicate index"
          end
        end
      end
    end
  end

  def self.down
    result = ActiveRecord::Migration::execute 'show tables'
    while table = result.fetch_row
      next if table.to_s == 'schema_info'
      
      fields = ActiveRecord::Migration::execute "show columns from #{table}"
            
      for field in fields
        field_name = field[0]
        
        for val in @fields_to_index
          begin
            remove_index table, field_name if field_name.to_s.include?(val) 
          rescue
            ActiveRecord::Migration::say "ERROR - unable to remove index #{table}_#{field_name}"
          end
        end
      end
    end
  end
end