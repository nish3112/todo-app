defmodule TodoAppFullWeb.TodoLive.PermissionFormComponent do
  use TodoAppFullWeb, :live_component
  alias TodoAppFull.Roles

  @impl true
  def render(assigns) do
    roles = Roles.fetch_roles()
    roles = Enum.filter(roles, fn(role) ->
      role.role != "Creator"
    end)

    ~H"""

    <div class="form-container">
      <div class="permission-form">
        Share todo with:
        <br>
        <form phx-submit="grant_permission" phx-target={@myself}>
        <div>
            <label for="todo-id">Todo ID:</label><br>
            <input type="text" id="todo-id" name="todo_id" disabled value={assigns.id}<br>
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

            <.button type="submit">
                Grant Permission
            </.button>

          </div>
        </form>
      </div>


      <div>
        Users with permission:

        <main class="container">
        <p class="alert alert-info" role="alert"
            phx-click="lv:clear-flash"
            phx-value-key="info"><%= live_flash(@flash, :info) %></p>

        <p class="alert alert-danger" role="alert"
            phx-click="lv:clear-flash"
            phx-value-key="error"><%= live_flash(@flash, :error) %></p>
        </main>

        <br>
        <ul>
          <%= for {_id, permission} <- @streams.permissions do %>
            <li>
              <%= permission.user.email %>: <%= permission.role.role %>
              <%= if permission.role.role != "Creator" do %>
                <button phx-click="remove_permission" phx-value-id={permission.id} phx-target={@myself}> <img src={~p"/images/close.png"} width="15" height="15"/> </button>
              <% end %>
            </li>
          <% end %>
        </ul>
      </div>




    </div>


    """
  end


  @impl true
def update(assigns, socket) do
  permissions = TodoAppFull.Permissions.list_permissions_for_todo(assigns[:id])
  IO.inspect(permissions)
  {:ok, socket |> stream(:permissions, permissions) |> assign(:id, assigns[:id])}
end


@impl true
def handle_event("grant_permission", %{"role_id" => role_id, "user_email" => user_email}, socket) do

  user_id = fetch_user_id(user_email)
  if user_id == nil do
    {:noreply, socket |> put_flash(:error, "Please try again later")}
  else
    updated_permission = TodoAppFull.Permissions.create_or_update_permission(user_id,socket.assigns.id,role_id)
    {:noreply, socket |> stream(:permissions, updated_permission) |> put_flash(:info, "Permission shared")}
  end

end

def handle_event("remove_permission", %{"id" => permission_id}, socket) do
  IO.inspect(permission_id, label: "Permission deleted for id : ")
  TodoAppFull.Permissions.remove_permission(permission_id)
  IO.inspect("Permission removed")
  permissions = TodoAppFull.Permissions.list_permissions_for_todo(socket.assigns.id)
  {:noreply, socket |> stream(:permissions, permissions, reset: true)}
end

  defp fetch_user_id(user_email) do
    user = TodoAppFull.Accounts.get_user_by_email(user_email)
    if user == nil do
      nil
    else
      user.id
    end
  end





end
