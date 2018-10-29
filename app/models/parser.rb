class Parser < ApplicationRecord
	has_attached_file :file
	validates_attachment :file, :content_type => { :content_type => "text/html" }
end
