class IssuesController < ApplicationController

  def create
    @issue = Issue.new(issue_params)
    if @issue.save
      if user_signed_in?
        @challengeing.user_id = current_user.id
        @issue.save
      end
    else
      render :new
    end
  end

  def show
    issue = Issue.find(params[:id])

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

  private
  def issue_params
    params.require(:issue).permit(:repository_name, :issue_id, :title, :detail, :cost)
  end

end
