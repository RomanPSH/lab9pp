class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]

  def index
    @posts = Post.all
    Rails.logger.info "Користувач отримав доступ до posts#index о #{Time.current}"
    begin
      1 / 0  # штучна помилка
    rescue ZeroDivisionError => e
      Sentry.capture_exception(e)
    end
    Sentry.capture_message("Відвідано index", level: "info")
  end

  def show
    Rails.logger.debug "Перегляд посту з ID: #{@post.id}"
    Sentry.capture_message("Відвідано show для посту з ID #{@post.id}", level: "info")
  end

  def new
    @post = Post.new
    Rails.logger.info "Користувач отримав доступ до posts#new для створення нового посту."
    Sentry.capture_message("Відвідано new", level: "info")
  end

  def edit
    Rails.logger.info "Користувач отримав доступ до posts#edit для посту з ID: #{@post.id}"
    Sentry.capture_message("Відвідано edit для посту з ID #{@post.id}", level: "info")
  end

  def create
    @post = Post.new(post_params)

    if @post.save
      Rails.logger.info "Пост успішно створено: #{@post.title}"
      redirect_to @post, notice: "Пост успішно створено."
    else
      message = "Не вдалося створити пост: #{@post.errors.full_messages.join(', ')}"
      Rails.logger.warn message
      Sentry.capture_message(message, level: "warning")
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @post.update(post_params)
      Rails.logger.info "Пост успішно оновлено: #{@post.id} - #{@post.title}"
      redirect_to @post, notice: "Пост успішно оновлено."
    else
      message = "Не вдалося оновити пост з ID: #{@post.id}. Помилки: #{@post.errors.full_messages.join(', ')}"
      Rails.logger.warn message
      Sentry.capture_message(message, level: "warning")
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    Rails.logger.info "Спроба видалення посту з ID: #{@post.id}"
    @post.destroy
    Rails.logger.warn "Пост видалено з ID: #{@post.id}"
    Sentry.capture_message("Пост з ID #{@post.id} видалено", level: "info")
    redirect_to posts_url, notice: "Пост успішно видалено."
  end

  private

    def set_post
      @post = Post.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.error "Пост з ID #{params[:id]} не знайдено."
      Sentry.capture_exception(e)
      redirect_to posts_url, alert: "Пост не знайдено."
    end

    def post_params
      params.require(:post).permit(:title, :content)
    end
end
