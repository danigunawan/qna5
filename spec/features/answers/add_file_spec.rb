require 'features/features_helper'

feature 'Add file to answers', %q{
  In order to illustrate my answers
  As an question's author
  I'd like to be able to attach files
  } do

  let(:user) { create(:user) }
  let(:question) { create(:question) }

  before {
    login_user
    visit question_path(question)
  }

  scenario 'User adds file when do answer', js:true do
    fill_in 'Answer', with: 'text text text'
    click_on 'Add attachment'
    attach_file 'File', "#{Rails.root}/spec/spec_helper.rb"
    click_on 'Add attachment'
    all('.fields').last.attach_file 'File', "#{Rails.root}/spec/rails_helper.rb"
    click_on 'Create'

    expect(page).to have_link 'spec_helper.rb', href: question.answers.last.attachments.first.file.url
    expect(page).to have_link 'rails_helper.rb', href: question.answers.last.attachments.last.file.url
  end
end
