namespace :neighborly_balanced_bankaccount do
  desc 'Update routing number table'
  task :update_routing_numbers => :environment do
    puts 'Fetching file from: fededirectory.frb.org...'
    url = URI.parse('http://www.fedwiredirectory.frb.org/FedACHdir.txt');
    http = Net::HTTP.new(url.host, url.port);
    response = http.request(Net::HTTP::Get.new(url.request_uri));

    puts 'Creating temp file...'
    tmp_file = Tempfile.new("routing_numbers_#{DateTime.now.to_i}")
    tmp_file.write response.body
    tmp_file.rewind
    puts "temp file --> #{tmp_file.inspect}"

    tmp_file.each_line do |line|
      number = line[0..8]
      bank_name = line[35...71]
      puts "#{number} -- #{bank_name.strip}"

      resource = Neighborly::Balanced::Bankaccount::RoutingNumber.find_or_create_by(number: number)
      resource.bank_name = bank_name.strip
      resource.save
    end
    tmp_file.unlink
    puts 'Done!'
  end
end
