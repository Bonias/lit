require 'test_helper'

module Lit
  class LocalizationKeysControllerTest < ActionController::TestCase
    fixtures :all

    setup do
      Lit.authentication_function = nil
      @routes = Lit::Engine.routes
      @i18n_file = File.expand_path(
        '../../../i18n_fixtures/localization_keys_controller.yml', __FILE__)
      I18n.load_path << @i18n_file
    end

    teardown do
      I18n.load_path.delete(@i18n_file)
    end

    test 'should destroy localization key, reload cache after destroy and return translation loaded from file' do
      @localization     = lit_localizations(:hello_world)
      @localization_key = @localization.localization_key

      delete :destroy, id: @localization_key.id, format: :js
      assert_response :success

      assert_not Lit::LocalizationKey.where(id: @localization_key.id).exists?
      assert_not Lit::Localization.where(id: @localization.id).exists?

      assert_equal 'Hello from file', I18n.t('scopes.hello_world')
    end
  end
end
