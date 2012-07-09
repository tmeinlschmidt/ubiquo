require File.dirname(__FILE__) + "/../../test_helper.rb"
class Ubiquo::AttachmentControllerTest < ActionController::TestCase

  def setup
    # We setup tmp as private_path to avoid errors when the real
    # directory doesn't exit.
    @private_path = Ubiquo::Settings.get(:attachments)[:private_path]
    @tmp_path = 'tmp'
    Ubiquo::Settings.get(:attachments)[:private_path] = @tmp_path
  end

  def teardown
    Ubiquo::Settings.get(:attachments)[:private_path] = @private_path
  end

  def test_should_not_be_able_to_request_attachments_outside_the_private_path
    assert_raises ActiveRecord::RecordNotFound do
      get(:show, { :path => '../config/routes.rb'})
    end
  end

  def test_should_be_able_to_obtain_attachments_inside_private_path_when_logged_in
    get(:show, { :path => File.basename(dummy_file.path) })
    assert_response :success
  end

  def test_should_not_be_able_to_obtain_attachment_when_not_logged_in
    @controller.expects(:login_required)
    get(:show, { :path => File.basename(dummy_file.path) })
  end

  protected

  def dummy_file
    Tempfile.new('dummy', Rails.root.join(@tmp_path)).tap do |file|
      file.flush
    end
  end

end
