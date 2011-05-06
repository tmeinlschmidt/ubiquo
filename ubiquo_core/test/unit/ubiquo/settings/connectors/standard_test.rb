require File.dirname(__FILE__) + "/../../../../../../../../test/test_helper.rb"

module Connectors
  class StandardTest < ActiveSupport::TestCase

      def setup
        save_current_settings_connector 
        Ubiquo::Settings[:settings_connector] = :standard
        Ubiquo::SettingsConnectors.load!
        Ubiquo::Settings.regenerate_settings
      end
      
      def teardown
        clear_settings
        reload_old_settings_connector
      end

      test "i18n is loaded by default when i18n plugin accesible" do
        assert Ubiquo::SettingsConnectors::Standard, Ubiquo::SettingsConnectors::Base.current_connector
      end

      test "should load values from database backend" do
        
        create_settings_test_case = lambda {
          Ubiquo::Settings.create_context(:foo)
          Ubiquo::Settings.create_context(:foo2)
          create_setting(:context => 'foo', :key => 'first', :value => 'value1')
          create_setting(:context => 'foo', :key => 'second', :value => 'value2')
          create_setting(:context => 'foo', :key => 'third', :value => 'value3')
          create_setting(:context => 'foo2', :key => 'first', :value => 'value4')
        }

        create_overrides_test_case = lambda {
          StringSetting.create(:context => :foo, :key => 'first', :value => 'value1_redefinido')
          StringSetting.create(:context => :foo, :key => 'second', :value => 'value2_redefinido')
          StringSetting.create(:context => :foo2, :key => 'first', :value => 'value3_redefinido')
        }

        enable_settings_override        
        create_settings_test_case.call
        create_overrides_test_case.call
        
        assert_equal 'value1_redefinido', Ubiquo::Settings[:foo][:first]

        Ubiquo::Settings.reset_overrides
        clear_settings
        enable_settings_override        
        create_settings_test_case.call

        assert_equal 'value1', Ubiquo::Settings[:foo][:first]
             
        create_overrides_test_case.call
        assert_equal 'value1_redefinido', Ubiquo::Settings[:foo].get(:first)
       
        clear_settings
        assert !Ubiquo::Settings.context_exists?(:foo)
                
        StringSetting.any_instance.stubs(:apply).returns(false)
        create_settings_test_case.call
        
        StringSetting.create(:context => :foo, :key => 'first', :value => 'value1_redefinido')
        assert_equal 'value1', Ubiquo::Settings[:foo][:first]
        enable_settings_override
        Ubiquo::Settings.load_from_backend!     
        assert_equal 'value1_redefinido', Ubiquo::Settings[:foo][:first]
      end

      test "create settings migration" do
        ActiveRecord::Migration.expects(:create_table).with(:settings).once
        ActiveRecord::Migration.uhook_create_settings_table
      end

      test "should accept a override if setting is editable" do
        enable_settings_override
        Ubiquo::Settings.create_context(:foo_context_1)
        Ubiquo::Settings[:foo_context_1].add(:new_setting, 
                                         'hola',
                                         {
                                           :is_editable => false,
                                         })
                        
        s1 = StringSetting.create(:context => :foo_context_1, :key => :new_setting, :value => 'hola_redefinido')
        assert s1.errors

        Ubiquo::Settings[:foo_context_1].set(:new_setting, 
                                         'hola',
                                         {
                                           :is_editable => true,
                                         })
        s1 = StringSetting.create(:context => :foo_context_1, :key => :new_setting, :value => 'hola_redefinido')
        assert_equal 'hola_redefinido', Ubiquo::Settings[:foo_context_1][:new_setting]
      end

    private

    def create_setting options = {}
      default_options = {
        :context => 'foo',
        :key => 'setting_key',
        :value => 'one',
        :options => {
          :is_editable => true,
        }
      }.merge(options)
      Ubiquo::Settings[default_options[:context].to_sym].add(default_options[:key], 
                                                    default_options[:value],
                                                    default_options[:options])
    end

    def clear_settings
      Setting.destroy_all
      Ubiquo::Settings.settings[:ubiquo] = @old_configuration.clone
      Ubiquo::Settings.settings.reject! { |k, v| !@initial_contexts.include?(k)}
    end

    def save_current_settings_connector
      @old_connector = Ubiquo::SettingsConnectors::Base.current_connector
      @initial_contexts =  Ubiquo::Settings.settings.keys
      @old_configuration = Ubiquo::Settings.settings[Ubiquo::Settings.default_context].clone
      
      Ubiquo::SettingsConnectors.load!
    end

    def reload_old_settings_connector
      clear_settings
      @old_connector.load!      
    end

  end
end
