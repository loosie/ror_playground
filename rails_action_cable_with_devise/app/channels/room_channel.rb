class RoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "room_#{params[:room_id]}_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def get_user_data
    data = {
      id: current_user.id,
      email: current_user.email,
      username: current_user.email.split('@')[0],
    }

    ActionCable.server.broadcast "room_channel", { data: data }
  end
end
