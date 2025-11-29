import { useState } from 'react';
import { Plus, Check, Clock } from 'lucide-react';

type TaskStatus = 'todo' | 'done';

interface SimpleTask {
  id: string;
  title: string;
  assignee: string;
  dueTime?: string;
  status: TaskStatus;
  category: string;
}

const mockTasks: SimpleTask[] = [
  { id: '1', title: 'Clean bar area', assignee: 'Tom', dueTime: '22:00', status: 'todo', category: 'Cleaning' },
  { id: '2', title: 'Restock beer fridge', assignee: 'Lisa', dueTime: '18:00', status: 'todo', category: 'Inventory' },
  { id: '3', title: 'Prepare garnishes', assignee: 'Tom', dueTime: '17:00', status: 'done', category: 'Bar' },
  { id: '4', title: 'Count cash register', assignee: 'Sarah', dueTime: '03:00', status: 'todo', category: 'Closing' },
];

export function Tasks() {
  const [tasks, setTasks] = useState<SimpleTask[]>(mockTasks);
  const [showAdd, setShowAdd] = useState(false);
  const [newTask, setNewTask] = useState({ title: '', assignee: '', dueTime: '' });

  const todoTasks = tasks.filter(t => t.status === 'todo');
  const doneTasks = tasks.filter(t => t.status === 'done');

  const toggleTask = (id: string) => {
    setTasks(tasks.map(t =>
      t.id === id ? { ...t, status: t.status === 'todo' ? 'done' : 'todo' } : t
    ));
  };

  const addTask = () => {
    if (!newTask.title.trim()) return;
    setTasks([...tasks, {
      id: Date.now().toString(),
      title: newTask.title,
      assignee: newTask.assignee || 'Unassigned',
      dueTime: newTask.dueTime,
      status: 'todo',
      category: 'General'
    }]);
    setNewTask({ title: '', assignee: '', dueTime: '' });
    setShowAdd(false);
  };

  return (
    <div className="max-w-2xl mx-auto space-y-6 animate-fade-in">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-foreground">Tasks</h1>
          <p className="text-foreground-muted">{todoTasks.length} remaining today</p>
        </div>
        <button
          onClick={() => setShowAdd(true)}
          className="flex items-center gap-2 px-4 py-2 bg-gradient-primary text-white rounded-xl hover:opacity-90 transition-all shadow-glow-sm"
        >
          <Plus size={18} />
          <span>Add</span>
        </button>
      </div>

      {/* Add Task Form */}
      {showAdd && (
        <div className="glass-card p-4 rounded-xl space-y-3 animate-scale-in">
          <input
            type="text"
            placeholder="What needs to be done?"
            value={newTask.title}
            onChange={(e) => setNewTask({ ...newTask, title: e.target.value })}
            className="w-full px-4 py-3 bg-white/5 border border-border rounded-xl text-foreground placeholder-foreground-dim focus:outline-none focus:border-primary-500"
            autoFocus
          />
          <div className="flex gap-3">
            <input
              type="text"
              placeholder="Assign to..."
              value={newTask.assignee}
              onChange={(e) => setNewTask({ ...newTask, assignee: e.target.value })}
              className="flex-1 px-4 py-2 bg-white/5 border border-border rounded-xl text-foreground placeholder-foreground-dim focus:outline-none focus:border-primary-500"
            />
            <input
              type="time"
              value={newTask.dueTime}
              onChange={(e) => setNewTask({ ...newTask, dueTime: e.target.value })}
              className="px-4 py-2 bg-white/5 border border-border rounded-xl text-foreground focus:outline-none focus:border-primary-500"
            />
          </div>
          <div className="flex gap-2">
            <button
              onClick={() => setShowAdd(false)}
              className="flex-1 px-4 py-2 bg-white/10 text-foreground rounded-xl hover:bg-white/20 transition-all"
            >
              Cancel
            </button>
            <button
              onClick={addTask}
              className="flex-1 px-4 py-2 bg-gradient-primary text-white rounded-xl hover:opacity-90 transition-all"
            >
              Add Task
            </button>
          </div>
        </div>
      )}

      {/* To Do */}
      <div className="space-y-2">
        <h2 className="text-sm font-medium text-foreground-muted uppercase tracking-wide">To Do</h2>
        {todoTasks.length === 0 ? (
          <div className="text-center py-8 text-foreground-dim">
            <Check size={32} className="mx-auto mb-2 text-success" />
            <p>All done!</p>
          </div>
        ) : (
          <div className="space-y-2">
            {todoTasks.map((task) => (
              <div
                key={task.id}
                onClick={() => toggleTask(task.id)}
                className="flex items-center gap-4 p-4 glass-card rounded-xl cursor-pointer hover:border-primary-500/50 transition-all group"
              >
                <div className="w-6 h-6 rounded-full border-2 border-foreground-dim group-hover:border-primary-500 transition-all flex items-center justify-center">
                  {/* Empty circle */}
                </div>
                <div className="flex-1">
                  <p className="text-foreground font-medium">{task.title}</p>
                  <p className="text-sm text-foreground-muted">{task.assignee}</p>
                </div>
                {task.dueTime && (
                  <div className="flex items-center gap-1 text-sm text-foreground-muted">
                    <Clock size={14} />
                    {task.dueTime}
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Done */}
      {doneTasks.length > 0 && (
        <div className="space-y-2">
          <h2 className="text-sm font-medium text-foreground-muted uppercase tracking-wide">Done</h2>
          <div className="space-y-2">
            {doneTasks.map((task) => (
              <div
                key={task.id}
                onClick={() => toggleTask(task.id)}
                className="flex items-center gap-4 p-4 glass-card rounded-xl cursor-pointer opacity-60 hover:opacity-80 transition-all"
              >
                <div className="w-6 h-6 rounded-full bg-success flex items-center justify-center">
                  <Check size={14} className="text-white" />
                </div>
                <div className="flex-1">
                  <p className="text-foreground font-medium line-through">{task.title}</p>
                  <p className="text-sm text-foreground-muted">{task.assignee}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
