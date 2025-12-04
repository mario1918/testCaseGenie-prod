import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { NotificationService } from '../../../services/notification.service';

@Component({
  selector: 'app-toast-notification',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './toast-notification.component.html',
  styles: []
})
export class ToastNotificationComponent {
  notificationService = inject(NotificationService);

  get toastClass(): string {
    return this.notificationService.type() === 'success' ? 'bg-green-500' : 'bg-red-500';
  }
}
