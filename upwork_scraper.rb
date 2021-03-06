require 'selenium-webdriver'
class UpworkScraper
  def initialize(search_term = "rails")
    @search = search_term
  end
  def scrape
    setup
    clear_cookies
    visit_root
    loop_on_root_if_needed
    enter_and_search_term
    extract_all_data
    log_matching_freelancers
    load_random_freelancer
    visit_freelancer_profile_page
    extract_freelancer_data
    match_freelancer_data
  end
  def setup
    options = Selenium::WebDriver::Firefox::Options.new()
    @driver = Selenium::WebDriver.for(:firefox, options: options)
  end
  def clear_cookies
    @driver.manage.delete_all_cookies if(@driver.manage.respond_to? :delete_all_cookies)
    puts "cookies deleted"
  end
  def visit_root
    @page = @driver.get("https://www.upwork.com")
    sleep 5
  end
  def loop_on_root_if_needed
    counter = 5
    while(counter > 0 && (@driver.find_elements(css: ".navbar-form form input.form-control").length == 0 || @driver.find_elements(css: ".navbar-form form input.form-control").last.attribute("placeholder") != "Find Freelancers"))
      puts "looping on root"
      visit_root
      counter -= 1
    end
  end
  def enter_and_search_term
    @driver.find_elements(css: ".navbar-form form input.form-control")
    @driver.execute_script("document.getElementsByName('q')[2].value = '#{@search}'")
    sleep 5
    @driver.find_elements(tag_name: 'button')[7].submit
  end
  def extract_all_data
    sleep 5
    @freelancers = @driver.find_elements(css: "section.air-card-hover")
    @freelancers_data = @freelancers.collect{|t|
      title = t.find_element(css: "h4.freelancer-tile-title").text
      all_internal = t.find_element(css: ".row .col-xs-12").text
      description = t.find_elements(css: ".d-lg-block").last.text
      skills = t.find_elements(css: ".row a.o-tag-skill").collect{|y| y.text}
      name = t.find_elements(css: "a.freelancer-tile-name").last.text
      {
        title: title,
        all_internal: all_internal,
        description: description,
        skills: skills,
        link: t.find_elements(css: "a.freelancer-tile-name").last.attribute("href"),
        name: name
      }
    }
  end
  def log_matching_freelancers
    @freelancers_data.each_with_index do |f, i|
      puts "freelancer #{i} (#{f[:name]})"
      fields.each do |fi|
        if f[fi].to_s.match(/#{@search}/i)
          puts "\t#{fi} matches #{@search}"
        else
          puts "\t#{fi} does not match #{@search}"
        end
      end
      puts
    end
  end
  def fields
    [:description, :title, :skills]
  end
  def load_random_freelancer
    length = @freelancers.length
    freelancer_or_not = []
    @freelancers_data.each_with_index do |x, index|
      if x[:link].match(/profiles/)
        freelancer_or_not << [index, x]
      end
    end
    allowed_indexes = freelancer_or_not.collect{|x, y| x}
    @index = allowed_indexes.shuffle.first
    @freelancer = @freelancers[@index]
  end
  def visit_freelancer_profile_page
    @freelancer.find_elements(css: "a.freelancer-tile-name").last.click
  end
  def extract_freelancer_data
    data = @driver.find_element(css: ".fe-profile-header")
    data2 = data.find_element(css: ".overlay-container")
    title = data2.find_element(css: "h3").text
    description = data2.find_elements(css: "o-profile-overview").first.text
    skills = @driver.find_elements(css: "cfe-profile-skills-integration a.o-tag-skill").collect{|t| t.text}
    @freelancer_data = {
      title: title,
      description: description,
      skills: skills
    }
  end
  def match_freelancer_data
    parent = @freelancers_data[@index]
    child = @freelancer_data
    puts "for freelancer #{parent[:name]}, comparing results page fields with internal page fields:"
    [:description, :title, :skills].each do |field|
      check_equality(parent, child, field, parent[:name])
    end
  end
  def check_equality(parent, child, field, name)
    if parent[field] == child[field]
      puts "\t#{field.to_s} matches for #{name} on both results page and internal page"
    else
      puts "\t#{field.to_s} does not match for #{name} on results page vs internal page"
    end
  end

end

if __FILE__==$0
  ups = UpworkScraper.new(ARGV[0])
  ups.scrape
end
