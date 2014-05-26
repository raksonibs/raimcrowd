module FixturesTestHelper
  def attributes_for_notification(type)
    fixture = Rails.root.join('..',
                              '..',
                              'spec',
                              'fixtures',
                              'notifications',
                              "#{type}.yml")
    YAML.load(File.read(fixture)).with_indifferent_access
  end
end
