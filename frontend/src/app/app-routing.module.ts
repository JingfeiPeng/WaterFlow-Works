import { CoursePathComponent } from './course-path/course-path.component';
import { InputformComponent } from './inputform/inputform.component';
import { HomepageComponent } from './homepage/homepage.component';
import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

const routes: Routes = [
  {
    path:"input",
    component: InputformComponent
  },
  {
    path:"coursePath",
    component: CoursePathComponent
  },
  {
      path: '**',
      component: HomepageComponent,
  },
];


@NgModule({
  imports: [
      RouterModule.forRoot(routes)
  ],
  exports: [
      RouterModule
  ],
  declarations: []
})
export class AppRoutingModule { }