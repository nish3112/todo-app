defmodule TodoAppFullWeb.FlopConfig do

def pagination_opts do
  [
    page_links: :all,
    wrapper_attrs: [
      class: "text-center mt-4"
    ],
    previous_link_content: Phoenix.HTML.raw("&larr; Previous"),
    previous_link_attrs: [
      class: "p-2 mr-2 border rounded border-slate-500"
    ],

    next_link_content: Phoenix.HTML.raw("Next &rarr;"),
    next_link_attrs: [
      class: "p-2 mr-2 border rounded border-slate-500"
    ]
  ]
end



end
