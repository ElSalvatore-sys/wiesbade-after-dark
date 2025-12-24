/**
 * LoadingButton - Button with loading state and spinner
 */

import React from 'react';
import type { ReactNode } from 'react';
import { motion } from 'framer-motion';
import { Loader2 } from 'lucide-react';
import { cn } from '../../lib/utils';

type ButtonVariant = 'primary' | 'secondary' | 'danger' | 'ghost' | 'outline';
type ButtonSize = 'sm' | 'md' | 'lg';

interface LoadingButtonProps {
  children: ReactNode;
  isLoading?: boolean;
  loadingText?: string;
  variant?: ButtonVariant;
  size?: ButtonSize;
  leftIcon?: ReactNode;
  rightIcon?: ReactNode;
  fullWidth?: boolean;
  disabled?: boolean;
  className?: string;
  onClick?: () => void;
  type?: 'button' | 'submit' | 'reset';
}

const variantStyles: Record<ButtonVariant, string> = {
  primary: 'bg-purple-600 hover:bg-purple-700 text-white border-transparent',
  secondary: 'bg-gray-700 hover:bg-gray-600 text-white border-transparent',
  danger: 'bg-red-600 hover:bg-red-700 text-white border-transparent',
  ghost: 'bg-transparent hover:bg-gray-800 text-gray-300 border-transparent',
  outline: 'bg-transparent hover:bg-gray-800 text-gray-300 border-gray-600',
};

const sizeStyles: Record<ButtonSize, string> = {
  sm: 'px-3 py-1.5 text-sm gap-1.5',
  md: 'px-4 py-2 text-sm gap-2',
  lg: 'px-6 py-3 text-base gap-2',
};

const spinnerSizes: Record<ButtonSize, string> = {
  sm: 'w-3 h-3',
  md: 'w-4 h-4',
  lg: 'w-5 h-5',
};

export const LoadingButton: React.FC<LoadingButtonProps> = ({
  children,
  isLoading = false,
  loadingText,
  variant = 'primary',
  size = 'md',
  leftIcon,
  rightIcon,
  fullWidth = false,
  disabled,
  className,
  onClick,
  type = 'button',
}) => {
  const isDisabled = disabled || isLoading;

  return (
    <motion.button
      whileHover={isDisabled ? {} : { scale: 1.02 }}
      whileTap={isDisabled ? {} : { scale: 0.98 }}
      disabled={isDisabled}
      onClick={onClick}
      type={type}
      className={cn(
        'inline-flex items-center justify-center font-medium rounded-lg border transition-colors',
        'focus:outline-none focus:ring-2 focus:ring-purple-500 focus:ring-offset-2 focus:ring-offset-gray-900',
        'disabled:opacity-50 disabled:cursor-not-allowed',
        variantStyles[variant],
        sizeStyles[size],
        fullWidth && 'w-full',
        className
      )}
    >
      {isLoading ? (
        <>
          <Loader2 className={cn('animate-spin', spinnerSizes[size])} />
          <span>{loadingText || children}</span>
        </>
      ) : (
        <>
          {leftIcon && <span className="flex-shrink-0">{leftIcon}</span>}
          <span>{children}</span>
          {rightIcon && <span className="flex-shrink-0">{rightIcon}</span>}
        </>
      )}
    </motion.button>
  );
};

// Simple icon button with loading state
export const IconButton: React.FC<{
  icon: ReactNode;
  isLoading?: boolean;
  variant?: ButtonVariant;
  size?: ButtonSize;
  className?: string;
  onClick?: () => void;
  disabled?: boolean;
  title?: string;
}> = ({
  icon,
  isLoading = false,
  variant = 'ghost',
  size = 'md',
  className,
  onClick,
  disabled,
  title,
}) => {
  const iconSizes: Record<ButtonSize, string> = {
    sm: 'p-1.5',
    md: 'p-2',
    lg: 'p-3',
  };

  return (
    <motion.button
      whileHover={disabled || isLoading ? {} : { scale: 1.1 }}
      whileTap={disabled || isLoading ? {} : { scale: 0.9 }}
      disabled={disabled || isLoading}
      onClick={onClick}
      title={title}
      className={cn(
        'inline-flex items-center justify-center rounded-lg transition-colors',
        'focus:outline-none focus:ring-2 focus:ring-purple-500',
        'disabled:opacity-50 disabled:cursor-not-allowed',
        variantStyles[variant],
        iconSizes[size],
        className
      )}
    >
      {isLoading ? (
        <Loader2 className={cn('animate-spin', spinnerSizes[size])} />
      ) : (
        icon
      )}
    </motion.button>
  );
};

// Button group for related actions
export const ButtonGroup: React.FC<{
  children: ReactNode;
  className?: string;
}> = ({ children, className }) => (
  <div className={cn('inline-flex rounded-lg overflow-hidden', className)}>
    {React.Children.map(children, (child, index) => (
      <div className={cn(index > 0 && 'border-l border-gray-600')}>
        {child}
      </div>
    ))}
  </div>
);

export default LoadingButton;
