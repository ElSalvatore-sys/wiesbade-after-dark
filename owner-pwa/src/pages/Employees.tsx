import { useState } from 'react';
import { Plus, Phone, Mail, X } from 'lucide-react';

type Role = 'owner' | 'manager' | 'staff';

interface TeamMember {
  id: string;
  name: string;
  role: Role;
  phone?: string;
  email?: string;
}

const mockTeam: TeamMember[] = [
  { id: '1', name: 'Max Müller', role: 'owner', phone: '+49 611 1234567', email: 'max@daswohnzimmer.de' },
  { id: '2', name: 'Sarah Schmidt', role: 'manager', phone: '+49 611 2345678', email: 'sarah@daswohnzimmer.de' },
  { id: '3', name: 'Tom Weber', role: 'staff', phone: '+49 611 3456789' },
  { id: '4', name: 'Lisa Fischer', role: 'staff', email: 'lisa@daswohnzimmer.de' },
];

const roleColors: Record<Role, string> = {
  owner: 'bg-accent-purple/20 text-accent-purple',
  manager: 'bg-accent-pink/20 text-accent-pink',
  staff: 'bg-accent-cyan/20 text-accent-cyan',
};

export function Employees() {
  const [team, setTeam] = useState<TeamMember[]>(mockTeam);
  const [showAdd, setShowAdd] = useState(false);
  const [newMember, setNewMember] = useState({ name: '', role: 'staff' as Role, phone: '', email: '' });

  const addMember = () => {
    if (!newMember.name.trim()) return;
    setTeam([...team, {
      id: Date.now().toString(),
      name: newMember.name,
      role: newMember.role,
      phone: newMember.phone || undefined,
      email: newMember.email || undefined,
    }]);
    setNewMember({ name: '', role: 'staff', phone: '', email: '' });
    setShowAdd(false);
  };

  const groupedByRole = {
    owner: team.filter(m => m.role === 'owner'),
    manager: team.filter(m => m.role === 'manager'),
    staff: team.filter(m => m.role === 'staff'),
  };

  return (
    <div className="max-w-2xl mx-auto space-y-6 animate-fade-in">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-foreground">Team</h1>
          <p className="text-foreground-muted">{team.length} members</p>
        </div>
        <button
          onClick={() => setShowAdd(true)}
          className="flex items-center gap-2 px-4 py-2 bg-gradient-primary text-white rounded-xl hover:opacity-90 transition-all shadow-glow-sm"
        >
          <Plus size={18} />
          <span>Add</span>
        </button>
      </div>

      {/* Add Modal */}
      {showAdd && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={() => setShowAdd(false)} />
          <div className="relative w-full max-w-sm glass-card p-5 animate-scale-in space-y-4">
            <div className="flex items-center justify-between">
              <h2 className="text-lg font-bold text-foreground">Add Team Member</h2>
              <button onClick={() => setShowAdd(false)} className="p-1 text-foreground-muted hover:text-foreground">
                <X size={20} />
              </button>
            </div>

            <input
              type="text"
              placeholder="Name"
              value={newMember.name}
              onChange={(e) => setNewMember({ ...newMember, name: e.target.value })}
              className="w-full px-4 py-3 bg-white/5 border border-border rounded-xl text-foreground placeholder-foreground-dim focus:outline-none focus:border-primary-500"
              autoFocus
            />

            <select
              value={newMember.role}
              onChange={(e) => setNewMember({ ...newMember, role: e.target.value as Role })}
              className="w-full px-4 py-3 bg-white/5 border border-border rounded-xl text-foreground focus:outline-none focus:border-primary-500"
            >
              <option value="staff">Staff</option>
              <option value="manager">Manager</option>
              <option value="owner">Owner</option>
            </select>

            <input
              type="tel"
              placeholder="Phone (optional)"
              value={newMember.phone}
              onChange={(e) => setNewMember({ ...newMember, phone: e.target.value })}
              className="w-full px-4 py-3 bg-white/5 border border-border rounded-xl text-foreground placeholder-foreground-dim focus:outline-none focus:border-primary-500"
            />

            <input
              type="email"
              placeholder="Email (optional)"
              value={newMember.email}
              onChange={(e) => setNewMember({ ...newMember, email: e.target.value })}
              className="w-full px-4 py-3 bg-white/5 border border-border rounded-xl text-foreground placeholder-foreground-dim focus:outline-none focus:border-primary-500"
            />

            <div className="flex gap-2 pt-2">
              <button
                onClick={() => setShowAdd(false)}
                className="flex-1 px-4 py-2 bg-white/10 text-foreground rounded-xl hover:bg-white/20 transition-all"
              >
                Cancel
              </button>
              <button
                onClick={addMember}
                className="flex-1 px-4 py-2 bg-gradient-primary text-white rounded-xl hover:opacity-90 transition-all"
              >
                Add
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Team List by Role */}
      {(['owner', 'manager', 'staff'] as Role[]).map((role) => (
        groupedByRole[role].length > 0 && (
          <div key={role} className="space-y-2">
            <h2 className="text-sm font-medium text-foreground-muted uppercase tracking-wide">
              {role === 'owner' ? 'Owners' : role === 'manager' ? 'Managers' : 'Staff'}
            </h2>
            <div className="space-y-2">
              {groupedByRole[role].map((member) => (
                <div
                  key={member.id}
                  className="flex items-center gap-4 p-4 glass-card rounded-xl"
                >
                  {/* Avatar */}
                  <div className="w-12 h-12 rounded-full bg-gradient-to-br from-primary-500 to-accent-pink flex items-center justify-center text-white font-bold text-lg">
                    {member.name.split(' ').map(n => n[0]).join('')}
                  </div>

                  {/* Info */}
                  <div className="flex-1 min-w-0">
                    <p className="text-foreground font-medium">{member.name}</p>
                    <span className={`inline-block text-xs font-medium px-2 py-0.5 rounded-md ${roleColors[member.role]}`}>
                      {member.role.charAt(0).toUpperCase() + member.role.slice(1)}
                    </span>
                  </div>

                  {/* Contact Buttons */}
                  <div className="flex gap-2">
                    {member.phone && (
                      <a
                        href={`tel:${member.phone}`}
                        className="p-2 rounded-lg bg-success/20 text-success hover:bg-success/30 transition-all"
                      >
                        <Phone size={18} />
                      </a>
                    )}
                    {member.email && (
                      <a
                        href={`mailto:${member.email}`}
                        className="p-2 rounded-lg bg-primary-500/20 text-primary-400 hover:bg-primary-500/30 transition-all"
                      >
                        <Mail size={18} />
                      </a>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>
        )
      ))}
    </div>
  );
}
