require File.dirname(__FILE__) + '/../test_helper'

class NewsletterExtensionTest < Test::Unit::TestCase  
  
  def test_initialization
    assert_equal File.join(File.expand_path(RAILS_ROOT), 'vendor', 'extensions', 'newsletter'), NewsletterExtension.root
    assert_equal 'Newsletter', NewsletterExtension.extension_name
  end
  
end
