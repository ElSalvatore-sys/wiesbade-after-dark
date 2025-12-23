import React from 'react';
import * as ToastPrimitive from '@radix-ui/react-toast';
import { X, CheckCircle, AlertCircle, AlertTriangle, Info } from 'lucide-react';
import { cn } from '../../lib/utils';

export type ToastType = 'success' | 'error' | 'warning' | 'info';

interface ToastProps {
  id: string;
  type: ToastType;
  title: string;
  description?: string;
  duration?: number;
  onClose: (id: string) => void;
}

const icons = {
  success: CheckCircle,
  error: AlertCircle,
  warning: AlertTriangle,
  info: Info,
};

const styles = {
  success: 'bg-green-900/90 border-green-500/50 text-green-100',
  error: 'bg-red-900/90 border-red-500/50 text-red-100',
  warning: 'bg-yellow-900/90 border-yellow-500/50 text-yellow-100',
  info: 'bg-blue-900/90 border-blue-500/50 text-blue-100',
};

const iconStyles = {
  success: 'text-green-400',
  error: 'text-red-400',
  warning: 'text-yellow-400',
  info: 'text-blue-400',
};

export const Toast: React.FC<ToastProps> = ({
  id,
  type,
  title,
  description,
  duration = 5000,
  onClose,
}) => {
  const Icon = icons[type];

  return (
    <ToastPrimitive.Root
      duration={duration}
      onOpenChange={(open) => !open && onClose(id)}
      className={cn(
        'flex items-start gap-3 p-4 rounded-lg border shadow-lg',
        'data-[state=open]:animate-in data-[state=closed]:animate-out',
        'data-[state=open]:slide-in-from-right-full',
        'data-[state=closed]:slide-out-to-right-full',
        'data-[state=closed]:fade-out-80',
        styles[type]
      )}
    >
      <Icon className={cn('w-5 h-5 mt-0.5 flex-shrink-0', iconStyles[type])} />
      
      <div className="flex-1 min-w-0">
        <ToastPrimitive.Title className="font-semibold text-sm">
          {title}
        </ToastPrimitive.Title>
        {description && (
          <ToastPrimitive.Description className="text-sm opacity-90 mt-1">
            {description}
          </ToastPrimitive.Description>
        )}
      </div>
      
      <ToastPrimitive.Close className="p-1 rounded hover:bg-white/10 transition-colors">
        <X className="w-4 h-4" />
      </ToastPrimitive.Close>
    </ToastPrimitive.Root>
  );
};

export const ToastViewport: React.FC = () => (
  <ToastPrimitive.Viewport className="fixed bottom-4 right-4 flex flex-col gap-2 w-96 max-w-[calc(100vw-2rem)] z-50" />
);

export { ToastPrimitive };
