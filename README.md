# Release Party - Celebrate Successful Deployments

NOTE: This is completely ALPHA right now, I don't recommend you use it.

Release party is a simple Capistrano plugin, which takes some configurable
actions when you've successfully deployed your project. These include:

* Send out a deployment notice by email
* Mark finished features as delivered in Pivotal Tracker
* Announce delivery using campfire
* Record deploy statistics using a deployment tracker

## Install

Add the release party gem to your project environment, e.g:

    gem install release_party

or for bundler:

    gem 'release_party'

Require Release Party in your Capfile, e.g:

    require 'release_party'

Tell Release Party how to celebrate by specifying options in the Releasefile in
your project root.

    # Get pivotal api key from the mac os x keyring and specify the pivotal project id
    project_api_key         { `security find-generic-password -ga pivotal 2>&1`.match(/password: "(.*)"/)[1] }
    project_id              295755

    # Deliver finished pivotal stories
    deliver_finished        true

    # Send deployment email to...
    email_notification_to   'jebarker+releaseparty@gmail.com'

    # Use the specified haml template
    template                'spec/assets/template.html.haml'

Deploy!

## Configuring

Release Party allows you to set a custom set of variables that control Release
Party only in a Releasefile, with a very basic syntax. It can also use Capfile
variables if they are defined.

Any values set in the Release Party environment are available inside the email
template. e.g:

    %h2 Known bugs
    #known_bugs
      - known_bugs.each do |story|
        .story[story]
          .bug
            .title
              %a{:href => story.url, :target => '_blank'}= story.id
              = '-'
              = story.name

The code above will show the known bugs obtained from your pivotal tracker
project.

### Configuring Pivotal

Pivotal integration requires the 'pivotal-tracker' gem. To use pivotal you must
set the following configuration variables:

    project_api_key  # The Pivotal API Key
    project_id       # The ID of the Pivotal project you are deploying

If these are specified the following variables get loaded for use in other
tasks:

    finished_stories # An array of (PivotalTracker::Story) features in the finished state
    known_bugs       # An array of (PivotalTracker::Story) bugs that have not been delivered

Optionally you can specify:

    deliver_finished true # Set to true to mark all finished stories as delivered on deploy

### Configuring Mail

Mail integration requires the 'mail' gem and a template engine such as 'haml'
or 'erb' (default is haml).

The mailer celebration takes a template (Haml or ERB) which has access to all
the release party and capistrano configuration values, renders it then delivers
it to the specified address. A sample Haml template is included in
spec/assets/template.html.haml which demonstrates examples of listing features
to approve and known bugs.

It uses the following variables:

    email_notificaton_to   # The email address or addresses (as an array of strings) to deliver the deployment notifications to
    from_address           # The from address of the email (defaults to releaseparty@noreply.org)
    smtp_address           # The address of the SMTP server to use for mail delivery (defaults to localhost)
    smtp_port              # The port of the SMTP server to use for delivery (defaults to 25)
    template_engine        # The template engine to use, defaults to :haml but can also be set to :erb
    subject                # The subject of the deployment email

### Configuring Campfire

Campfire integration requires the 'tinder' gem.

    campfire_account       # Campfire account user name
    campfire_room          # The room to announce in
    campfire_token         # The API token to use when connecting to campfire

## Contributing

We encourage all community contributions. Keeping this in mind, please follow
these general guidelines when contributing:

* Fork the project
* Create a topic branch for what you’re working on (git checkout -b
  awesome_feature)
* Commit away, push that up (git push your\_remote awesome\_feature)
* Create a new GitHub Issue with the commit, asking for review. Alternatively,
  send a pull request with details of what you added.
* Once it’s accepted, if you want access to the core repository feel free to
  ask! Otherwise, you can continue to hack away in your own fork.

Other than that, our guidelines very closely match the GemCutter guidelines
[here](http://wiki.github.com/qrush/gemcutter/contribution-guidelines).

(Thanks to [GemCutter](http://wiki.github.com/qrush/gemcutter/) for the
contribution guide)

## License

(The MIT License)

Copyright (c) 2009, 2010, 2011

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the 'Software'), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
