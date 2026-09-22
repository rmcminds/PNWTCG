document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll(".sortable-checklist").forEach((container) => {
    const lists = container.querySelectorAll("ul.task-list");

    lists.forEach((list) => {
      const items = Array.from(list.children).filter((node) => node.tagName === "LI");

      items.sort((a, b) => {
        const aChecked = a.classList.contains("task-list-item") && a.classList.contains("task-list-item-checkbox-checked");
        const bChecked = b.classList.contains("task-list-item") && b.classList.contains("task-list-item-checkbox-checked");

        if (aChecked === bChecked) {
          return 0;
        }

        return aChecked ? 1 : -1;
      });

      items.forEach((item) => list.appendChild(item));
    });
  });
});
