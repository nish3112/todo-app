defmodule TodoAppFullWeb.TodoLive.PermissionFormComponent do
  use TodoAppFullWeb, :live_component
  alias TodoAppFull.Roles

  @impl true
  def render(assigns) do
    roles = Roles.fetch_roles()
    permissions = TodoAppFull.Permissions.list_permissions_for_todo(assigns[:id])

    ~H"""
    <div>
      Share todo with:
      <br>
      <form phx-submit="grant_permission">
      <div>
          <label for="todo-id">Todo ID:</label><br>
          <input type="text" id="todo-id" name="todo_id" disabled value={@id}<br>
        </div>
        <br>
        <div>
          <label for="role-id">Role:</label><br>
          <select id="role-id" name="role_id">
            <%= for role <- roles do %>
              <option value={role.id} ><%= role.role %></option>
            <% end %>
          </select><br>
        </div>
        <br>
        <div>
          <label for="user-email">User Email:</label><br>
          <input type="email" id="user-email" name="user_email"><br>
        </div>
        <br>
        <div>
          <.button type="submit">Grant Permission</.button>
        </div>
      </form>

      <div>
        Users with permission:
        <br>
        <ul>
          <%= for permission <- permissions do %>
            <li>
              <%= permission.user.email %>: <%= permission.role.role %>
              <%= if permission.role.role != "Creator" do %>
                <button phx-click="remove_permission" phx-value-id={permission.id}>Remove</button>
              <% end %>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end


end
