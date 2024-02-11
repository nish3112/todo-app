defmodule TodoAppFullWeb.TodoLive.PermissionFormComponent do
  use TodoAppFullWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      ALLOW PERMISSONS HERE
    </div>
    """
  end


  # @impl true
  # def update(assigns, socket) do
  #   changeset = TodoAppFull.Permissions.change_permission(socket.assigns.permission)

  #   {:ok, assign(socket, permissionForm: to_form(changeset))}
  # end

  # @impl true
  # def handle_event("validate", %{"permission" => permission_params}, socket) do
  #   changeset =
  #     socket.assigns.permission
  #     |> TodoAppFull.Permissions.change_permission(permission_params)
  #     |> Map.put(:action, :validate)

  #   {:noreply, assign(socket, permissionForm: to_form(changeset))}
  # end

  # def handle_event("save", %{"permission" => permission_params}, socket) do
  #   save_permission(socket, socket.assigns.action, permission_params)
  # end

  # defp save_permission(socket, :update, permission_params) do
  #   case TodoAppFull.Permissions.update_permission(socket.assigns.permission, permission_params) do
  #     {:ok, permission} ->
  #       notify_parent({:saved, permission})

  #       {:noreply,
  #        socket
  #        |> put_flash(:info, "Permission updated successfully")
  #        |> push_patch(to: socket.assigns.patch)}

  #     {:error, changeset} ->
  #       {:noreply, assign(socket, permissionForm: to_form(changeset))}
  #   end
  # end

  # defp save_permission(socket, :new, permission_params) do
  #   case TodoAppFull.Permissions.create_permission(permission_params) do
  #     {:ok, permission} ->
  #       notify_parent({:saved, permission})

  #       {:noreply,
  #        socket
  #        |> put_flash(:info, "Permission created successfully")
  #        |> push_patch(to: socket.assigns.patch)}

  #     {:error, changeset} ->
  #       {:noreply, assign(socket, permissionForm: to_form(changeset))}
  #   end
  # end

  # defp assign_form(socket, changeset) do
  #   assign(socket, permissionForm: to_form(changeset))
  # end

  # defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
