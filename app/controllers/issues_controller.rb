class IssuesController < ApplicationController

  def create
  end

  def show
    issue = Issue.find(params[:id])

    require 'net/http'
    if issue.is_opened
      uri = URI.parse("https://api.github.com/repos/#{issue.user.github_user_id}/#{issue.repository_name}/issues?state=close")
      json = Net::HTTP.get(uri)
      json = JSON.parse(json)
      json.each do |data|
        if data["number"].to_i == issue.github_issue_id.to_i
          if data["state"] == "closed"
            issue.update(is_opened: false)
          end
        end
      end
    end
    uri = URI.parse("https://api.github.com/repos/#{issue.user.github_user_id}/#{issue.repository_name}/issues?state=close")
    json = Net::HTTP.get(uri)
    json = JSON.parse(json)
    json.each do |data|
      puts '=================='
      pp data
      puts '=================='
    end

    repository_url = "https://github.com/#{issue.user.github_user_id}/#{issue.repository_name}"
    issue_url = repository_url + "/issues/#{issue.github_issue_id}"

    challenges = []
    issue.challenges.each do |challenge|
      challenges << {
        detail: challenge.detail,
        status: challenge.status,
        issue_id: challenge.issue_id,
        user: {
          id: challenge.user_id,
          name: challenge.user.name,
        }
      }
    end

    render json: {
      is_my_issue: @user.id == issue.user_id,
      user: {
        name: @user.name,
        detail: @user.detail,
      },
      issue: {
        title: issue.title,
        detail: issue.detail,
        repository_url: repository_url,
        issue_url: issue_url,
        cost: issue.cost,
        user: {
          name: issue.user.name,
          detail: issue.user.detail,
        },
      },
      challenges: challenges,
    }
  end

end
