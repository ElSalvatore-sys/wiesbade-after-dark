/**
 * Hook for managing bulk selection state
 * Supports: single select, shift+click range, select all
 */

import { useState, useCallback, useMemo } from 'react';

interface UseBulkSelectOptions<T> {
  items: T[];
  getItemId: (item: T) => string;
}

interface UseBulkSelectReturn<T> {
  selectedIds: Set<string>;
  selectedItems: T[];
  isSelected: (id: string) => boolean;
  toggle: (id: string, shiftKey?: boolean) => void;
  selectAll: () => void;
  deselectAll: () => void;
  selectRange: (fromId: string, toId: string) => void;
  isAllSelected: boolean;
  isSomeSelected: boolean;
  selectedCount: number;
}

export function useBulkSelect<T>({
  items,
  getItemId,
}: UseBulkSelectOptions<T>): UseBulkSelectReturn<T> {
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set());
  const [lastSelectedId, setLastSelectedId] = useState<string | null>(null);

  const isSelected = useCallback(
    (id: string) => selectedIds.has(id),
    [selectedIds]
  );

  const toggle = useCallback(
    (id: string, shiftKey = false) => {
      setSelectedIds((prev) => {
        const next = new Set(prev);

        // Shift+click for range selection
        if (shiftKey && lastSelectedId) {
          const itemIds = items.map(getItemId);
          const lastIndex = itemIds.indexOf(lastSelectedId);
          const currentIndex = itemIds.indexOf(id);

          if (lastIndex !== -1 && currentIndex !== -1) {
            const start = Math.min(lastIndex, currentIndex);
            const end = Math.max(lastIndex, currentIndex);

            for (let i = start; i <= end; i++) {
              next.add(itemIds[i]);
            }
            return next;
          }
        }

        // Normal toggle
        if (next.has(id)) {
          next.delete(id);
        } else {
          next.add(id);
        }

        return next;
      });

      setLastSelectedId(id);
    },
    [items, getItemId, lastSelectedId]
  );

  const selectAll = useCallback(() => {
    setSelectedIds(new Set(items.map(getItemId)));
  }, [items, getItemId]);

  const deselectAll = useCallback(() => {
    setSelectedIds(new Set());
    setLastSelectedId(null);
  }, []);

  const selectRange = useCallback(
    (fromId: string, toId: string) => {
      const itemIds = items.map(getItemId);
      const fromIndex = itemIds.indexOf(fromId);
      const toIndex = itemIds.indexOf(toId);

      if (fromIndex === -1 || toIndex === -1) return;

      const start = Math.min(fromIndex, toIndex);
      const end = Math.max(fromIndex, toIndex);

      setSelectedIds((prev) => {
        const next = new Set(prev);
        for (let i = start; i <= end; i++) {
          next.add(itemIds[i]);
        }
        return next;
      });
    },
    [items, getItemId]
  );

  const selectedItems = useMemo(
    () => items.filter((item) => selectedIds.has(getItemId(item))),
    [items, selectedIds, getItemId]
  );

  const isAllSelected = items.length > 0 && selectedIds.size === items.length;
  const isSomeSelected = selectedIds.size > 0 && selectedIds.size < items.length;
  const selectedCount = selectedIds.size;

  return {
    selectedIds,
    selectedItems,
    isSelected,
    toggle,
    selectAll,
    deselectAll,
    selectRange,
    isAllSelected,
    isSomeSelected,
    selectedCount,
  };
}

export default useBulkSelect;
