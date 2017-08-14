! -*- Mode: Fortran; -*- 

      subroutine error_handler(communicator, error_code)
      use mpi_f08
      implicit none
      type(MPI_Comm) communicator
      integer error_code

      type(MPI_Comm) new_comm
      integer ierr
      type(MPI_Comm) comm_all
      common /myerrhand/ comm_all

      call MPIX_Comm_revoke(comm=comm_all, ierror=ierr)
      call MPIX_Comm_shrink(comm=comm_all, newcomm=new_comm, ierror=ierr)

      call MPI_Comm_free(comm_all, ierr)

      comm_all = new_comm
      end subroutine

      program main
      use mpi_f08
      implicit none
      integer rank, size, i, ierr
      integer sum, val
      integer errs
      type(MPI_Errhandler) :: errhandler
      type(MPI_Comm) comm_all
      common /myerrhand/ comm_all
      procedure(MPI_Comm_errhandler_function) :: error_handler

      sum = 0
      val = 1
      errs = 0

      call MPI_Init(ierr)
      call MPI_Comm_rank(MPI_COMM_WORLD, rank, ierr)
      call MPI_Comm_size(MPI_COMM_WORLD, size, ierr)

      if (size .lt. 4) then
         write(*,*) "Must run with at least 4 processes."
         call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
      end if

      call MPI_Comm_dup(MPI_COMM_WORLD, comm_all, ierr)

      call MPI_Comm_create_errhandler(error_handler, errhandler, ierr)
      call MPI_Comm_set_errhandler(comm_all, errhandler, ierr)

      do i = 0, 9
         call MPI_Comm_size(comm_all, size, ierr)
         sum = 0;
         if ((i .eq. 5) .and. (rank .eq. 1)) then
            error stop "FORTRAN STOP"
         else if (i .ne. 5) then
            call MPI_Allreduce(val, sum, 1, MPI_INTEGER, MPI_SUM, &
     &                         comm_all, ierr)
            if ((sum .ne. size) .and. (rank .eq. 0)) then
               errs = errs + 1
               write(*,*) "Incorrect answer:", sum, "!=", size
            end if
         end if
      end do

      if ((0 .eq. rank) .and. (errs .ne. 0)) then
         write(*,*) " Found", errs, "errors"
      else if (0 .eq. rank) then
         write(*,*) " No errors"
      end if

      call MPI_Comm_free(comm_all, ierr)
      call MPI_Errhandler_free(errhandler, ierr)

      call MPI_Finalize(ierr)

      end program