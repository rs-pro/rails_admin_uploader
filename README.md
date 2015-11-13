# RailsAdminUploader

Mass file uploads via [jQuery-File-Upload](https://github.com/blueimp/jQuery-File-Upload) for Rails Admin

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rails_admin_uploader'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rails_admin_uploader

Mount the gem's engine. Add to ```config/routes.rb```:

    mount RailsAdminUploader::Engine => '/ra_uploader', as: 'rails_admin_uploader'

Add this line to ```app/assets/javascripts/rails_admin/custom/ui.coffee```

    #= require rails_admin_uploader

Create this file if it doesn't exist in your project.


Add this line to ```app/assets/stylesheets/rails_admin/custom/theming.sass```

    @import rails_admin_uploader

Create this file if it doesn't exist in your project.


## Usage

Configure your models:

  class Obj
    has_many :images
    has_many :plans
    include RailsAdminUploader::Base
    rails_admin_uploader :images, :plans
    # add a string field :ra_token to DB (required)
    rails_admin do
      edit do
        field :image, :rails_admin_uploader
        field :plans, :rails_admin_uploader
      end
    end
  end
  class Image
    belongs_to :obj
    include RailsAdminUploader::Asset

    # add a string field :ra_token to DB (required)
    # add an image field :image to DB (required)
    # add an integer field :sort to DB (optional)
    # add a boolean field :enabled to DB (optional)
  end

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/rs-pro/rails_admin_uploader).

## License

Somewhat based on [rails-uploader](https://github.com/superp/rails-uploader)
Copyright (c) 2013 Fodojo, released under the MIT license

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
Copyright (c) 2015 glebtv, released under the MIT license

