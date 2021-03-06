module UbiquoCategories
  module Connectors
    class Base < Ubiquo::Connectors::Base

      # Load all the modules required for an UbiquoCategories connector
      def self.load!
        ::Category.reset_column_information
        if current = UbiquoCategories::Connectors::Base.current_connector
          current.unload!
        end
        return if validate_requirements == false
        prepare_mocks if Rails.env.test?
        ::ActiveRecord::Base.send(:include, self::ActiveRecord::Base)
        :Category.include! self::Category
        :CategorySet.include! self::CategorySet
        :UbiquoController.helper! self::UbiquoHelpers::Helper
        :"Ubiquo::CategoriesController".include! self::UbiquoCategoriesController
        ::ActiveRecord::Migration.send(:include, self::Migration)
        UbiquoCategories::Connectors::Base.set_current_connector self
      end

    end
  end
end
